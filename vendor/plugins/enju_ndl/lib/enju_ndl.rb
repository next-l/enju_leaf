# -*- encoding: utf-8 -*-
module EnjuNdl
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_ndl
    #  include EnjuNdl::InstanceMethods
    end

    def import_isbn(isbn)
      isbn = ISBN_Tools.cleanup(isbn)
      raise EnjuNdl::InvalidIsbn unless ISBN_Tools.is_valid?(isbn)

      manifestation = Manifestation.find_by_isbn(isbn)
      return manifestation if manifestation

      doc = return_xml(isbn)
      raise EnjuNdl::RecordNotFound unless doc
      #raise EnjuNdl::RecordNotFound if doc.at('//openSearch:totalResults').content.to_i == 0

      pub_date, language, nbn = nil, nil, nil

      publishers = get_publishers(doc).zip([]).map{|f,t| {:full_name => f, :full_name_transcription => t}}

      # title
      title = get_title(doc)

      # date of publication
      pub_date = doc.at('//dcterms:date').content.to_s.gsub(/\./, '-')
      unless pub_date =~ /^\d+(-\d{0,2}){0,2}$/
        pub_date = nil
      end
      language = get_language(doc)
      isbn = doc.at('./dc:identifier[@xsi:type="dcndl:ISBN"]').try(:content).to_s
      nbn = doc.at('//dcterms:identifier[@rdf:datatype="http://ndl.go.jp/dcndl/terms/JPNO"]').content
      classification_urls = doc.xpath('//dcterms:subject[@rdf:resource]').map{|subject| subject.attributes['resource'].value}
      if classification_urls
        ndc9_url = classification_urls.map{|url| URI.parse(url)}.select{|u| u.path.split('/').reverse[1] == 'ndc9'}.first
        if ndc9_url
          ndc = ndc9_url.path.split('/').last
        end
      end
      description = doc.at('//dcterms:abstract').try(:content)

      manifestation = nil
      Patron.transaction do
        publisher_patrons = Patron.import_patrons(publishers)
        language_id = Language.where(:iso_639_2 => language).first.id rescue 1

        manifestation = Manifestation.new(
          :original_title => title[:manifestation],
          :title_transcription => title[:transcription],
          # TODO: PORTAに入っている図書以外の資料を調べる
          #:carrier_type_id => CarrierType.where(:name => 'print').first.id,
          :language_id => language_id,
          :isbn => isbn,
          :pub_date => pub_date,
          :nbn => nbn
        )
        manifestation.publishers << publisher_patrons
        #manifestation.save!
      end

      #manifestation.send_later(:create_frbr_instance, doc.to_s)
      create_frbr_instance(doc, manifestation)
      return manifestation
    end

    def import_isbn!(isbn)
      manifestation = import_isbn(isbn)
      manifestation.save!
      manifestation
    end

    def search_ndl(query, options = {})
      options = {:dpid => 'iss-ndl-opac', :item => 'any', :startrecord => 1, :per_page => 10, :raw => false}.merge(options)
      doc = nil
      results = {}
      startrecord = options[:startrecord].to_i
      if startrecord == 0
        startrecord = 1
      end
      url = "http://iss.ndl.go.jp/api/opensearch?dpid=#{options[:dpid]}&#{options[:item]}=#{URI.escape(query)}&cnt=#{options[:per_page]}&idx=#{startrecord}"
      if options[:raw] == true
        open(url).read
      else
        RSS::Rss::Channel.install_text_element("openSearch:totalResults", "http://a9.com/-/spec/opensearchrss/1.0/", "?", "totalResults", :text, "openSearch:totalResults")
        RSS::BaseListener.install_get_text_element "http://a9.com/-/spec/opensearchrss/1.0/", "totalResults", "totalResults="
        feed = RSS::Parser.parse(url, false)
      end
    end

    def return_xml(isbn)
      rss = self.search_ndl(isbn, {:dpid => 'iss-ndl-opac', :item => 'isbn'})
      if rss.channel.totalResults.to_i == 0
        isbn = normalize_isbn(isbn)
        rss = self.search_ndl(isbn, {:dpid => 'iss-ndl-opac', :item => 'isbn'})
      end
      if rss.items.first
        doc = Nokogiri::XML(open("#{rss.items.first.link}.rdf").read)
      end
    end

    def get_crd_response(options)
      params = {:query_logic => 1, :results_num => 1, :results_num => 200, :sort => 10}.merge(options)
      query = []
      query << "01_#{params[:query_01].to_s.gsub('　', ' ')}" if params[:query_01]
      query << "02_#{params[:query_02].to_s.gsub('　', ' ')}" if params[:query_02]
      delimiter = '.'
      url = "http://crd.ndl.go.jp/refapi/servlet/refapi.RSearchAPI?query=#{URI.escape(query.join(delimiter))}&query_logic=#{params[:query_logic]}&results_get_position=#{params[:results_get_position]}&results_num=#{params[:results_num]}&sort=#{params[:sort]}"

      xml = open(url).read.to_s
    end

    def search_crd(options)
      params = {:page => 1}.merge(options)
      crd_page = params[:page].to_i
      crd_page = 1 if crd_page <= 0
      crd_startrecord = (crd_page - 1) * Question.crd_per_page + 1
      params[:results_get_position] = crd_startrecord
      params[:results_num] = Question.crd_per_page

      xml = get_crd_response(params)
      doc = Nokogiri::XML(xml)

      response = {
        :results_num => doc.at('//xmlns:hit_num').try(:content).to_i,
        :results => []
      }
      doc.xpath('//xmlns:result').each do |result|
        set = {
          :question => result.at('QUESTION').try(:content),
          :reg_id => result.at('REG-ID').try(:content),
          :answer => result.at('ANSWER').try(:content),
          :crt_date => result.at('CRT-DATE').try(:content),
          :solution => result.at('SOLUTION').try(:content),
          :lib_id => result.at('LIB-ID').try(:content),
          :lib_name => result.at('LIB-NAME').try(:content),
          :url => result.at('URL').try(:content),
          :ndc => result.at('NDC').try(:content)
        }
        begin
          set[:keyword] = result.xpath('xmlns:KEYWORD').collect(&:content)
        rescue NoMethodError
          set[:keyword] = []
        end
        response[:results] << set
      end

      crd_count = response[:results_num]
      if crd_count > 1000
        crd_total_count = 1000
      else
        crd_total_count = crd_count
      end

      resources = response[:results]
      crd_results = WillPaginate::Collection.create(crd_page, Question.crd_per_page, crd_total_count) do |pager| pager.replace(resources) end
    end

    def normalize_isbn(isbn)
      if isbn.length == 10
        ISBN_Tools.isbn10_to_isbn13(isbn)
      else
        ISBN_Tools.isbn13_to_isbn10(isbn)
      end
    end

    def create_frbr_instance(doc, manifestation)
      title = get_title(doc)
      creators = get_creators(doc).zip([]).map{|f,t| {:full_name => f, :full_name_transcription => t}}
      language = get_language(doc)
      subjects = get_subjects(doc)

      Patron.transaction do
        creator_patrons = Patron.import_patrons(creators)
        language_id = Language.where(:iso_639_2 => language).first.id rescue 1
        content_type_id = ContentType.where(:name => 'text').first.id rescue 1
        manifestation.creators << creator_patrons
        subjects.each do |term|
          subject = Subject.where(:term => term).first
          manifestation.subjects << subject if subject
        end
      end
    end

    def rss_import(url)
      doc = Nokogiri::XML(open(url))
      ns = {"dc" => "http://purl.org/dc/elements/1.1/", "xsi" => "http://www.w3.org/2001/XMLSchema-instance", "dcndl" => "http://ndl.go.jp/dcndl/terms/"}
      doc.xpath('//item', ns).each do |item|
        isbn = item.at('./dc:identifier[@xsi:type="dcndl:ISBN"]').try(:content)
        ndl_bib_id = item.at('./dc:identifier[@xsi:type="dcndl:NDLBibID"]').try(:content)
        manifestation = Manifestation.where(:ndl_bib_id => ndl_bib_id).first
        manifestation = Manifestation.find_by_isbn(isbn) unless manifestation
        # FIXME: 日本語決めうち？
        language_id = Language.where(:iso_639_2 => 'jpn').first.id rescue 1
        unless manifestation
          manifestation = self.new(
            :original_title => item.at('./dc:title').content,
            :title_transcription => item.at('./dcndl:titleTranscription').try(:content),
            :isbn => isbn,
            :ndl_bib_id => ndl_bib_id,
            :description => item.at('./dc:description').try(:content),
            :pub_date => item.at('./dc:date').try(:content).try(:gsub, '.', '-'),
            :language_id => language_id
          )
          if manifestation.valid?
            item.xpath('./dc:creator').each_with_index do |creator, i|
              next if i == 0
              patron = Patron.where(:full_name => creator.try(:content)).first
              patron =  Patron.new(:full_name => creator.try(:content)) unless patron
              manifestation.creators << patron if patron.valid?
            end
            item.xpath('./dc:publisher').each_with_index do |publisher, i|
              patron = Patron.where(:full_name => publisher.try(:content)).first
              patron =  Patron.new(:full_name => publisher.try(:content)) unless patron
              manifestation.publishers << patron if patron.valid?
            end
          end
        end
      end
      Sunspot.commit
    end

    private
    def get_title(doc)
      title = {
        :manifestation => doc.xpath('//dc:title/rdf:Description/rdf:value').collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' '),
        :transcription => doc.xpath('//dc:title/dcndl:transcription').collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' '),
        :original => doc.xpath('//dcterms:alternative/rdf:Rescription/rdf:value').collect(&:content).join(' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      }
    end

    def get_creators(doc)
      creators = []
      doc.xpath('//dcterms:creator/foaf:Agent').each do |creator|
        creators << creator.at('./foaf:name').content.gsub('∥', '').gsub(',', ' ').tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ')
#        creators << {
#          :full_name => creator.at('./foaf:name').content,
#          :full_name_transcription => creator.at('./dcndl:transcription').try(:content)
#        }
      end
      return creators
    end

    def get_subjects(doc)
      subjects = []
      doc.xpath('//dcterms:subject/rdf:Description/rdf:value').each do |subject|
        subjects << subject.content.tr('ａ-ｚＡ-Ｚ０-９　∥', 'a-zA-Z0-9 ')
      end
      return subjects
    end

    def get_language(doc)
      # TODO: 言語が複数ある場合
      language = doc.xpath('//dcterms:language').first.content.downcase
    end

    def get_publishers(doc)
      publishers = []
      doc.xpath('//dcterms:publisher/foaf:Agent/foaf:name').each do |publisher|
        publishers << publisher.content.tr('ａ-ｚＡ-Ｚ０-９　∥', 'a-zA-Z0-9 ')
      end
      return publishers
    end
  end

  class RecordNotFound < StandardError
  end

  class InvalidIsbn < StandardError
  end
end
