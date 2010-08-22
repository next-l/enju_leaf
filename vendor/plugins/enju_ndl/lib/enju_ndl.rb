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
      raise EnjuNdl::RecordNotFound unless ISBN_Tools.is_valid?(isbn)

      if manifestation = Resource.first(:conditions => {:isbn => isbn})
      #  raise 'already imported'
      end

      doc = return_xml(isbn)
      raise EnjuNdl::RecordNotFound if doc.at('//openSearch:totalResults').content.to_i == 0

      date_of_publication, language, nbn = nil, nil, nil

      publishers = get_publishers(doc)

      # title
      title = get_title(doc)

      # date of publication
      date_of_publication = Time.mktime(doc.at('//dcterms:issued[@xsi:type="dcterms:W3CDTF"]').content)

      language = get_language(doc)
      nbn = doc.at('//dc:identifier[@xsi:type="dcndl:JPNO"]').content

      Patron.transaction do
        publisher_patrons = Patron.import_patrons(publishers)
        #language_id = Language.first(:conditions => {:iso_639_2 => language}).id || 1

        manifestation = Resource.new(
          :original_title => title[:manifestation],
          :title_transcription => title[:transcription],
          # TODO: PORTAに入っている図書以外の資料を調べる
          #:carrier_type_id => CarrierType.first(:conditions => {:name => 'print'}).id,
          #:language_id => language_id,
          :isbn => isbn,
          :date_of_publication => date_of_publication,
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

    def search_porta(query, options = {})
      options = {:item => 'any', :startrecord => 1, :per_page => 10, :raw => false}.merge(options)
      doc = nil
      results = {}
      startrecord = options[:startrecord].to_i
      if startrecord == 0
        startrecord = 1
      end
      url = "http://api.porta.ndl.go.jp/servicedp/opensearch?dpid=#{options[:dpid]}&#{options[:item]}=#{URI.escape(query)}&cnt=#{options[:per_page]}&idx=#{startrecord}"
      if options[:raw] == true
        open(url).read
      else
        RSS::Rss::Channel.install_text_element("openSearch:totalResults", "http://a9.com/-/spec/opensearchrss/1.0/", "?", "totalResults", :text, "openSearch:totalResults")
        RSS::BaseListener.install_get_text_element "http://a9.com/-/spec/opensearchrss/1.0/", "totalResults", "totalResults="
        feed = RSS::Parser.parse(url, false)
      end
    end

    def return_xml(isbn)
      xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
      doc = Nokogiri::XML(xml)
      if doc.at('//openSearch:totalResults').content.to_i == 0
        isbn = normalize_isbn(isbn)
        xml = self.search_porta(isbn, {:dpid => 'zomoku', :item => 'isbn', :raw => true}).to_s
        doc = Nokogiri::XML(xml)
      end
      return doc
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

      response = {}
      response[:results_num] = doc.at('//xmlns:hit_num').try(:content).to_i
      response[:results] = []
      doc.xpath('//xmlns:result').each do |result|
        set = {}
        set[:question] = result.at('QUESTION').try(:content)
        set[:reg_id] = result.at('REG-ID').try(:content)
        set[:answer] = result.at('ANSWER').try(:content)
        set[:crt_date] = result.at('CRT-DATE').try(:content)
        set[:solution] = result.at('SOLUTION').try(:content)
        set[:lib_id] = result.at('LIB-ID').try(:content)
        set[:lib_name] = result.at('LIB-NAME').try(:content)
        set[:url] = result.at('URL').try(:content)
        set[:ndc] = result.at('NDC').try(:content)
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

    def get_title(doc)
      title = {}
      title[:manifestation] = doc.xpath('//item[1]/title').collect(&:content).join(' ') #.tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      title[:transcription] = doc.xpath('//item[1]/dcndl:titleTranscription').collect(&:content).join(' ') #.tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      title[:original] = doc.xpath('//dcterms:alternative').collect(&:content).join(' ') #.tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      return title
    end

    def get_authors(doc)
      authors = []
      doc.xpath('//item[1]/dc:creator[@xsi:type="dcndl:NDLNH"]').each do |creator|
        authors << creator.content #.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return authors
    end

    def get_subjects(doc)
      subjects = []
      doc.xpath('//item[1]/dc:subject[@xsi:type="dcndl:NDLSH"]').each do |subject|
        subjects << subject.content #.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return subjects
    end

    def get_language(doc)
      # TODO: 言語が複数ある場合
      language = doc.xpath('//item[1]/dc:language[@xsi:type="dcterms:ISO639-2"]').first.content.downcase
    end

    def get_publishers(doc)
      publishers = []
      doc.xpath('//item[1]/dc:publisher').each do |publisher|
        publishers << publisher.content #.tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ')
      end
      return publishers
    end
  
    def create_frbr_instance(doc, manifestation)
      title = get_title(doc)
      authors = get_authors(doc)
      language = get_language(doc)
      subjects = get_subjects(doc)

      Patron.transaction do
        author_patrons = Patron.import_patrons(authors)
        language_id = Language.first(:conditions => {:iso_639_2 => language}).id rescue 1
        content_type_id = ContentType.first(:conditions => {:name => 'text'}).id rescue 1
        manifestation.creators << author_patrons
        subjects.each do |term|
          subject = Subject.first(:conditions => {:term => term})
          manifestation.subjects << subject if subject
          #subject = Tag.first(:conditions => {:name => term})
          #manifestation.tags << subject if subject
        end
      end
    end
  end

  class RecordNotFound < StandardError
  end

  class InvalidIsbn < StandardError
  end
end
