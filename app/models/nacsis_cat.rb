# encoding: utf-8

class NacsisCat
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :record

  class Error < StandardError
    def initialize(raw_result, message = nil)
      super(message)
      @raw_result = raw_result
    end
    attr_reader :raw_result
  end
  class ClientError < Error; end
  class ServerError < Error; end
  class UnknownError < Error; end

  class NetworkError < StandardError
    def initialize(orig_ex, message = nil)
      message ||= orig_ex.message
      super(message)
      @original_exception = orig_ex
    end
    attr_reader :original_exception
  end

  class ResultArray < Array
    def initialize(search_result)
      @raw_result = search_result
      @total = @raw_result.try(:[], 'total') || 0

      if @raw_result.try(:[], 'records')
        @raw_result['records'].each do |record|
          self << NacsisCat.new(:record => record)
        end
      end
    end
    attr_reader :raw_result, :total
  end

  class << self
    # NACSIS-CAT検索を実行する。検索結果はNacsisCatオブジェクトの配列で返す。
    # 検索条件は引数で指定する。サポートしている形式は以下の通り。
    #  * :dbs => [...] - 検索対象のDB名リスト: :book(一般書誌)、:serial(雑誌書誌)、:bhold(一般所蔵)、:shold(雑誌所蔵)、:all(:bookと:serialからの横断検索)
    #  * :opts => {...} - DBに対するオプション(ページ指定): 指定例: {:book => {:page => 2, :per_page => 30}, :serial => {...}}
    #  * :id => '...' - NACSIS-CATの書誌IDにより検索する
    #  * :bid => '...' - NACSIS-CATの書蔵IDにより検索する
    #  * :isbn => '...' - ISBN(ISBNKEY)により検索する
    #  * :issn => '...' - ISSN(ISSNKEY)により検索する
    #  * :query => '...' - 一般検索語により検索する(*)
    #  * :title => [...] - 書名(_TITLE_)により検索する(*)
    #  * :author => [...] - 著者名(_AUTH_)により検索する(*)
    #  * :publisher => [...] - 出版者名(PUBLKEY)により検索する(*)
    #  * :subject => [...] - 件名(SHKEY)により検索する(*)
    #  * :except => {...} - 否定条件により検索する(*)(**)
    #
    # (*) :dbsが:bookまたは:serialのときのみ機能する
    # (**) :query、:title、:author、:publisher、:subjectの否定形に対応
    #
    # :dbsには基本的に複数のDBを指定する。
    # 検索結果は {:book => aResultArray, ...} のような形となる。
    # なお、複数DBを指定した場合、すべてのDBに対して同じ条件で検索を行う。
    # このため、たとえば :dbs => [:book, :bhold] のように
    # まったく違う種類のDBを指定してもうまく動作しない。
    def search(*args)
      options = args.extract_options!
      options.assert_valid_keys(
        :dbs, :opts,
        :id, :isbn, :issn,
        :query, :title, :author, :publisher, :subject, :except)
      if options[:except]
        options[:except].assert_valid_keys(
          :query, :title, :author, :publisher, :subject)
      end

      dbs = options.delete(:dbs) || [:book]
      db_opts = options.delete(:opts) || {}

      if options.blank? || options.keys == [:except]
        return {}.tap do |h|
          dbs.each {|db| h[db] = ResultArray.new(nil) }
        end
      end

      if (dbs.include?(:shold) || dbs.include?(:bhold)) &&
          options.include?(:id)
        options[:bid] = options.delete(:id)
      end
      query = build_query(options)
      search_by_gateway(dbs: dbs, opts: db_opts, query: query)
    end

    private

      DB_KEY = {
        query: ['_TITLE_', '_AUTH_', 'PUBLKEY', 'SHKEY'],
        title: '_TITLE_',
        author: '_AUTH_',
        publisher: 'PUBLKEY',
        subject: 'SHKEY',
        id: 'ID',
        bid: 'BID',
        isbn: 'ISBNKEY',
        issn: 'ISSNKEY',
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

      def search_by_gateway(options)
        db_type = db_names = nil

        key_to_db = {
          all: '_ALL_',
          book: 'BOOK',
          serial: 'SERIAL',
          bhold: 'BHOLD',
          shold: 'SHOLD',
        }

        dbs = options[:dbs].map do |key|
          db = key_to_db[key]
          raise ArgumentError, "unknwon db: #{key}" unless db
          db
        end

        db_opts = {}
        options[:opts].each do |key, v|
          db = key_to_db[key]
          next unless db
          next unless dbs.include?(db)
          db_opts[db] = v
        end

        q = {}
        q[:db] = dbs
        q[:opts] = db_opts if db_opts.present?
        q[:query] = options[:query]

        url = "#{gateway_search_url}?#{q.to_query}"
        begin
          return_value = http_get_value(url)
        rescue SocketError, SystemCallError => ex
          raise NetworkError.new(ex)
        end

        case return_value['status']
        when 'success'
          ex = nil
        when 'user-error'
          ex = ClientError
        when 'gateway-error'
          ex = ServerError
        when 'server-error'
          ex = ServerError
        else
          ex = UnknownError
        end
        if ex
          raise ex.new(return_value, return_value['phrase'])
        end

        ret = {}
        db_to_key = key_to_db.invert
        return_value['results'].each_pair do |db, result|
          key = db_to_key[db]
          ret[key] = ResultArray.new(result)
        end

        ret
      end

      def gateway_config
        NACSIS_CLIENT_CONFIG[Rails.env]['gw_account']
      end

      def gateway_search_url
        url = gateway_config['gw_url']
        url.sub(%r{/*\z}, '/') + 'records'
      end

      def http_get_value(url)
        uri = URI(url)

        opts = {}
        if uri.scheme == 'https'
          opts[:use_ssl] =  true

          if gateway_config.include?('ssl_verify') &&
              gateway_config['ssl_verify'] == false
            # config/nacsis_client.ymlで'ssl_verify': falseのとき
            opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
          else
            opts[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
          end
        end

        resp = Net::HTTP.start(uri.host, uri.port, opts) do |h|
          h.get(uri.request_uri)
        end

        JSON.parse(resp.body)
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
    @record['_DBNAME_'] == 'SERIAL'
  end

  def item?
    @record['_DBNAME_'] == 'BHOLD' || @record['_DBNAME_'] == 'SHOLD'
  end

  def ncid
    @record['ID']
  end

  def isbn
    if book?
      map_attrs(@record['VOLG'], 'ISBN').compact
    else
      nil
    end
  end

  def issn
    if serial?
      @record['ISSN']
    else
      nil
    end
  end

  def summary
    return nil unless @record

    if item?
      hash = {
        :database => @record['_DBNAME_'],
        :hold_id => @record['ID'],
        :library_abbrev => @record['LIBABL'],
        :cln => map_attrs(@record['HOLD'], 'CLN').join(' '),
        :rgtn => map_attrs(@record['HOLD'], 'RGTN').join(' '),
      }

    else
      hash = {
        :subject_heading => @record['TR'].try(:[], 'TRD'),
        :publisher => map_attrs(@record['PUB']) {|x| [x['PUBL'], x['PUBDT']] },
      }

      if serial?
        hash[:display_number] = [@record['VLYR']].flatten
      else
        hash[:series_title] =
          map_attrs(@record['PTBL']) {|x| [x['PTBTR'], x['PTBNO']] }
      end
    end

    hash
  end

  def detail
    return nil unless @record

    {
      :subject_heading => @record['TR'].try(:[], 'TRD'),
      :subject_heading_reading => @record['TR'].try(:[], 'TRR'),
      :publisher => map_attrs(@record['PUB']) {|pub| join_attrs(pub, ['PUBP', 'PUBL', 'PUBDT'], ',') },
      :publish_year => join_attrs(@record['YEAR'], ['YEAR1', 'YEAR2'], '-'),
      :physical_description => join_attrs(@record['PHYS'], ['PHYSP', 'PHYSI', 'PHYSS', 'PHYSA'], ';'),
      :pub_country => @record['CNTRY'], # :pub_country => @record.cntry.try {|cntry| Country.where(:alpha_2 => cntry.upcase).first }, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
      :title_language => @record['TTLL'].try {|lang| Language.where(:iso_639_3 => lang).first },
      :text_language => @record['TXTL'].try {|lang| Language.where(:iso_639_3 => lang).first },
      :classmark => if book?
          map_attrs(@record['CLS']) {|cl| join_attrs(cl, ['CLSK', 'CLSD'], ':') }.join(';')
        else
          nil
        end,
      :author_heading => map_attrs(@record['AL']) do |al|
        if al['AHDNG'].blank? && al['AHDNGR'].blank?
          nil
        elsif al['AHDNG'] && al['AHDNGR']
          "#{al['AHDNG']}(#{al['AHDNGR']})"
        else
          al['AHDNG'] || al['AHDNGR']
        end
      end.compact,
      :subject => map_attrs(@record['SH'], 'SHD'),
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
      :subject_heading => @record['TR'].try(:[], 'TRD'),
      :publisher => map_attrs(@record['PUB']) {|pub| join_attrs(pub, ['PUBP', 'PUBL', 'PUBDT'], ',') }.join(' '),
      :pub_date => join_attrs(@record['YEAR'], ['YEAR1', 'YEAR2'], '-'),
      :physical_description => join_attrs(@record['PHYS'], ['PHYSP', 'PHYSI', 'PHYSS', 'PHYSA'], ';'),
      :series_title => if book?
          map_attrs(@record['PTBL']) {|x| [x['PTBTR'], x['PTBNO']].compact.join(' ') }.join(',')
        else
          nil
        end,
      :isbn => isbn.try(:join, ','),
      :pub_country => @record['CNTRY'], # :pub_country => @record['CNTRY'].try {|cntry| Country.where(:alpha_2 => cntry.upcase).first }, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
      :title_language => @record['TTLL'].try {|lang| Language.where(:iso_639_3 => lang).first },
      :text_language => @record['TXTL'].try {|lang| Language.where(:iso_639_3 => lang).first },
      :classmark => if book?
          map_attrs(@record['CLS']) {|cl| join_attrs(cl, ['CLSK', 'CLSD'], ':') }.join(';')
        else
          nil
        end,
      :author_heading => map_attrs(@record['AL']) do |al|
        if al['AHDNG'].blank? && al['AHDNGR'].blank?
          nil
        elsif al['AHDNG'] && al['AHDNGR']
          "#{al['AHDNG']}(#{al['AHDNGR']})"
        else
          al['AHDNG'] || al['AHDNGR']
        end
      end.compact.join(','),
      :subject => map_attrs(@record['SH'], 'SHD').join(','),
      :ncid => ncid,
    }.tap do |hash|
    end
  end

  def persisted?
    false
  end

  private

    def map_attrs(str_or_ary, key = nil, &block)
      return [] unless str_or_ary
      ary = [str_or_ary].flatten
      if block
        ary.map(&block)
      else
        ary.map {|x| x[key] }
      end
    end

    def join_attrs(obj, keys, str)
      if obj
        ary = keys.map {|k| obj[k] }.compact
        ary.blank? ? nil : ary.join(str)
      else
        obj
      end
    end
end
