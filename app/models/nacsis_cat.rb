# encoding: utf-8

class NacsisCat
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :record

  class Error < RuntimeError; end
  class ClientError < Error; end
  class ServerError < Error; end
  class UnknownError < Error; end

  class ResultArray < Array
    def initialize(search_result)
      @raw_result = search_result
      @total = @raw_result.try(:result_count) || 0

      if search_result.try(:result_records)
        search_result.result_records.each do |record|
          self << NacsisCat.new(:record => record)
        end
      end
    end
    attr_reader :raw_result, :total
  end

  class << self
    # NACSIS-CAT検索を実行する。検索結果はNacsisCatオブジェクトの配列で返す。
    # 検索条件は引数で指定する。サポートしている形式は以下の通り。
    #  * :db => '...' - 検索対象のDB名: :book(一般書誌)、:serial(雑誌書誌)、:bhold(一般所蔵)、:shold(雑誌所蔵)
    #  * :page => n - ページ番号
    #  * :per_page => n - ページあたりの件数
    #  * :id => '...' - NACSIS-CATの書誌IDにより検索する
    #  * :isbn => '...' - ISBN(ISBNKEY)により検索する
    #  * :issn => '...' - ISSN(ISSNKEY)により検索する
    #  * :query => '...' - 一般検索語により検索する(*)
    #  * :title => [...] - 書名(_TITLE_)により検索する(*)
    #  * :author => [...] - 著者名(_AUTH_)により検索する(*)
    #  * :publisher => [...] - 出版者名(PUBLKEY)により検索する(*)
    #  * :subject => [...] - 件名(SHKEY)により検索する(*)
    #  * :except => {...} - 否定条件により検索する(*)(**)
    #
    # (*) :dbが:bookまたは:serialのときのみ機能する
    # (**) :query、:title、:author、:publisher、:subjectの否定形に対応
    def search(*args)
      options = args.extract_options!
      options.assert_valid_keys(
        :db, :page, :per_page,
        :id, :isbn, :issn,
        :query, :title, :author, :publisher, :subject, :except)
      if options[:except]
        options[:except].assert_valid_keys(
          :query, :title, :author, :publisher, :subject)
      end

      db_option = options.delete(:db) || :book
      page = options.delete(:page)
      per_page = options.delete(:per_page)
      return ResultArray.new(nil) if options.blank? || options.keys == [:except]

      if (db_option == :shold || db_option == :bhold) &&
          options.include?(:id)
        options[:bid] = options.delete(:id)
      end
      query = build_query(options)
      request_gateway_to(:search, :db => db_option, :query => query, :per_page => per_page, :page => page)
    end

    private

      DB_KEY = {
        :query => ['_TITLE_', '_AUTH_', 'PUBLKEY', 'SHKEY'],
        :title => '_TITLE_',
        :author => '_AUTH_',
        :publisher => 'PUBLKEY',
        :subject => 'SHKEY',
        :id => 'ID',
        :bid => 'BID',
        :isbn => 'ISBNKEY',
        :issn => 'ISSNKEY',
      }
      def build_query(cond, inverse = false)
        if inverse
          op = 'OR'
        else
          op = 'AND'
        end

        except = cond.delete(:except)
        segments = cond.map do |key, value|
          case key
          when :id, :bid, :isbn, :issn
            rpn_seg(DB_KEY[key], value)

          when :title, :author, :publisher, :subject
            rpn_concat(
              op,
              [value].flatten.map {|v| rpn_seg(DB_KEY[key], v) })

          when :query
            rpn_concat(
              op,
              [value].flatten.map do |v|
                rpn_concat(
                  'OR', DB_KEY[:query].map {|k| rpn_seg(k, v) })
              end
            )
          end
        end

        if except.blank?
          rpn_concat(op, segments)
        else
          rpn_concat(
            'AND-NOT', [
              rpn_concat(op, segments),
              build_query(except, true)
            ])
        end
      end

      def rpn_concat(op, cond)
        cond.inject([]) do |ary, c|
          f = ary.empty?
          ary << c
          ary << op unless f
          ary
        end.join(' ')
      end

      def rpn_seg(key, value)
        %Q!#{key}="#{value.to_s.gsub(/[\\"]/, '\\\1')}"!
      end

      def request_gateway_to(action, options)
        db_type = db_names = nil
        case options[:db]
=begin
# NOTE:
# CATPプロトコル上はBOOK:SERIALの横断的検索が可能だと思われる。
# 実際、BOOK:SERIALでの検索を行うと両種類のレコードを含んだ応答がある。
# しかしながらenju_nacsis_gatewayはこのような応答に対応しておらず
# 結果的に横断的検索は行えない。
        when :all
          db_type = 'BOOK'
          db_names = %w(BOOK SERIAL)
=end
        when :book
          db_type = 'BOOK'
          db_names = %w(BOOK)
        when :serial
          db_type = 'SERIAL'
          db_names = %w(SERIAL)
        when :bhold
          db_type = 'BHOLD'
          db_names = %w(BHOLD)
        when :shold
          db_type = 'SHOLD'
          db_names = %w(SHOLD)
        else
          raise ArgumentError, "unknwon db: #{options[:db]}"
        end

        per_page = options[:per_page]
        page = options[:page] || 1

        cc = EnjuNacsisCatp::CatContainer.new
        case action
        when :search
          cc.db_type = db_type
          cc.db_names = db_names
          cc.query = options[:query]
          cc.command = 'SEARCH'
          if per_page
            cc.extra_options = {}
            cc.command = 'SEARCH_RETRIEVE'
            cc.extra_options[:search] = {
              'large_lower_bound' => 1,
            }
            cc.extra_options[:retrieve] = {
              'start_position' => per_page*(page - 1) + 1,
              'record_requested' => per_page,
            }
            cc.max_retrieve = per_page
          end

        else
          raise ArgumentError, "unknwon action: #{action}"
        end

        cgc = EnjuNacsisCatp::CatGatewayClient.new
        cgc.container = cc
        result = cgc.execute

        if result.has_errors?
          case result.catp_code
          when /\A4/
            ex = ClientError
          when /\A5/
            ex = ServerError
          else
            ex = UnknownError
          end
          raise ex.new(result.catp_errors.join(' '))
        end

        ResultArray.new(result)
      end
  end # class << self

  def initialize(*args)
    options = args.extract_options!
    options.assert_valid_keys(:record)

    @record = options[:record]
  end

  def book?
    !serial?
  end

  def serial?
    @record.is_a?(EnjuNacsisCatp::SerialInfo)
  end

  def item?
    @record.is_a?(EnjuNacsisCatp::BholdInfo) ||
      @record.is_a?(EnjuNacsisCatp::SholdInfo)
  end

  def ncid
    @record.bibliog_id
  end

  def isbn
    if book?
      @record.volgs.map {|vol| vol.isbn }.compact
    else
      nil
    end
  end

  def issn
    if serial?
      @record.issn
    else
      nil
    end
  end

  def summary
    return nil unless @record

    if item?
      hash = {
        :database => @record.dbname,
        :hold_id => @record.hold_id,
        :library_abbrev => @record.libabl,
        :cln => @record.holds.map(&:cln).join(' '),
        :rgtn => @record.holds.map(&:rgtn).join(' '),
      }

    else
      hash = {
        :subject_heading => @record.tr.try(:trd),
        :publisher => @record.pubs.map {|x| [x.publ, x.pubdt] },
      }

      if serial?
        hash[:display_number] = @record.vlyrs
      else
        hash[:series_title] =
          @record.ptbls.map {|x| [x.ptbtr, x.ptbno] }
      end
    end

    hash
  end

  def detail
    return nil unless @record

    {
      :subject_heading => @record.tr.try(:trd),
      :subject_heading_reading => @record.tr.try(:trr),
      :publisher => @record.pubs.map {|pub| join_attrs(pub, [:pubp, :publ, :pubdt], ',') },
      :publish_year => join_attrs(@record.year, [:year1, :year2], '-'),
      :physical_description => join_attrs(@record.phys, [:physp, :physi, :physs, :physa], ';'),
      :pub_country => @record.cntry, # :pub_country => @record.cntry.try {|cntry| Country.where(:alpha_2 => cntry.upcase).first }, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
      :title_language => @record.ttll.try {|lang| Language.where(:iso_639_3 => lang).first },
      :text_language => @record.txtl.try {|lang| Language.where(:iso_639_3 => lang).first },
      :classmark => if book?
          @record.cls.map {|cl| join_attrs(cl, [:clsk, :clsd], ':') }.join(';')
        else
          nil
        end,
      :author_heading => @record.als.map do |al|
        if al.ahdng.blank? && al.ahdngr.blank?
          nil
        elsif al.ahdng && al.ahdngr
          "#{al.ahdng}(#{al.ahdngr})"
        else
          al.ahdng || al.ahdngr
        end
      end.compact,
      :subject => @record.shs.map {|sh| sh.shd },
    }.tap do |hash|
        if book?
          hash[:isbn] = isbn
        else
          hash[:issn] = issn
        end
    end
  end

  def request_summary
    return nil unless @record

    {
      :subject_heading => @record.tr.try(:trd),
      :publisher => @record.pubs.map {|pub| join_attrs(pub, [:pubp, :publ, :pubdt], ',') }.join(' '),
      :pub_date => join_attrs(@record.year, [:year1, :year2], '-'),
      :physical_description => join_attrs(@record.phys, [:physp, :physi, :physs, :physa], ';'),
      :series_title => if book?
          @record.ptbls.map {|x| [x.ptbtr, x.ptbno].compact.join(' ') }.join(',')
        else
          nil
        end,
      :isbn => isbn.try(:join, ','),
      :pub_country => @record.cntry, # :pub_country => @record.cntry.try {|cntry| Country.where(:alpha_2 => cntry.upcase).first }, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
      :title_language => @record.ttll.try {|lang| Language.where(:iso_639_3 => lang).first },
      :text_language => @record.txtl.try {|lang| Language.where(:iso_639_3 => lang).first },
      :classmark => if book?
          @record.cls.map {|cl| join_attrs(cl, [:clsk, :clsd], ':') }.join(';')
        else
          nil
        end,
      :author_heading => @record.als.map do |al|
        if al.ahdng.blank? && al.ahdngr.blank?
          nil
        elsif al.ahdng && al.ahdngr
          "#{al.ahdng}(#{al.ahdngr})"
        else
          al.ahdng || al.ahdngr
        end
      end.compact.join(','),
      :subject => @record.shs.map {|sh| sh.shd }.join(','),
      :ncid => ncid,
    }.tap do |hash|
    end
  end

  def persisted?
    false
  end

  private

    def join_attrs(obj, attrs, str)
      if obj
        ary = attrs.map {|a| obj.__send__(a) }.compact
        ary.blank? ? nil : ary.join(str)
      else
        obj
      end
    end
end
