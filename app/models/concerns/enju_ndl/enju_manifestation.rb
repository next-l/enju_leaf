module EnjuNdl
  module EnjuManifestation
    extend ActiveSupport::Concern

    module ClassMethods
      def import_isbn(isbn)
        manifestation = Manifestation.import_from_ndl_search(isbn: isbn)
        manifestation
      end

      def ndl_bib_doc(ndl_bib_id)
        url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&version=1.2&query=itemno=#{ndl_bib_id}&recordSchema=dcndl&onlyBib=true"
        Nokogiri::XML(Nokogiri::XML(URI.parse(url).read).at('//xmlns:recordData').content)
      end

      # Use http://www.ndl.go.jp/jp/dlib/standards/opendataset/aboutIDList.txt
      def import_ndl_bib_id(ndl_bib_id)
        import_record(ndl_bib_doc(ndl_bib_id))
      end

      def import_from_ndl_search(options)
        # if options[:isbn]
        lisbn = Lisbn.new(options[:isbn])
        raise EnjuNdl::InvalidIsbn unless lisbn.valid?

        # end

        manifestation = Manifestation.find_by_isbn(lisbn.isbn)
        return manifestation.first if manifestation.present?

        doc = return_xml(isbn: lisbn.isbn)
        raise EnjuNdl::RecordNotFound unless doc

        # raise EnjuNdl::RecordNotFound if doc.at('//openSearch:totalResults').content.to_i == 0
        import_record(doc)
      end

      def import_record(doc)
        iss_itemno = URI.parse(doc.at('//dcndl:BibAdminResource[@rdf:about]').values.first).path.split('/').last
        identifier_type = IdentifierType.find_or_create_by!(name: 'iss_itemno')
        identifier = Identifier.find_by(body: iss_itemno, identifier_type_id: identifier_type.id)
        return identifier.manifestation if identifier

        jpno = doc.at('//dcterms:identifier[@rdf:datatype="http://ndl.go.jp/dcndl/terms/JPNO"]').try(:content)

        publishers = get_publishers(doc)

        # title
        title = get_title(doc)

        # date of publication
        pub_date = doc.at('//dcterms:issued').try(:content).to_s.tr('.', '-')
        pub_date = nil unless pub_date =~ /^\d+(-\d{0,2}){0,2}$/
        if pub_date
          date = pub_date.split('-')
          date = if date[0] && date[1]
                   format('%04d-%02d', date[0], date[1])
                 else
                   pub_date
                 end
        end

        language = Language.find_by(iso_639_2: get_language(doc))
        language_id = if language
                        language.id
                      else
                        1
                      end

        isbn = Lisbn.new(doc.at('//dcterms:identifier[@rdf:datatype="http://ndl.go.jp/dcndl/terms/ISBN"]').try(:content).to_s).try(:isbn)
        issn = StdNum::ISSN.normalize(doc.at('//dcterms:identifier[@rdf:datatype="http://ndl.go.jp/dcndl/terms/ISSN"]').try(:content))
        issn_l = StdNum::ISSN.normalize(doc.at('//dcterms:identifier[@rdf:datatype="http://ndl.go.jp/dcndl/terms/ISSNL"]').try(:content))

        carrier_type = content_type = nil
        is_serial = nil
        doc.xpath('//dcndl:materialType[@rdf:resource]').each do |d|
          case d.attributes['resource'].try(:content)
          when 'http://ndl.go.jp/ndltype/Book'
            carrier_type = CarrierType.find_by(name: 'print')
            content_type = ContentType.find_by(name: 'text')
          when 'http://ndl.go.jp/ndltype/Braille'
            content_type = ContentType.find_by(name: 'tactile_text')
          # when 'http://ndl.go.jp/ndltype/ComputerProgram'
          #  content_type = ContentType.find_by(name: 'computer_program')
          when 'http://ndl.go.jp/ndltype/ElectronicResource'
            carrier_type = CarrierType.find_by(name: 'file')
          when 'http://ndl.go.jp/ndltype/Journal'
            is_serial = true
          when 'http://ndl.go.jp/ndltype/Map'
            content_type = ContentType.find_by(name: 'cartographic_image')
          when 'http://ndl.go.jp/ndltype/Music'
            content_type = ContentType.find_by(name: 'performed_music')
          when 'http://ndl.go.jp/ndltype/MusicScore'
            content_type = ContentType.find_by(name: 'notated_music')
          when 'http://ndl.go.jp/ndltype/Painting'
            content_type = ContentType.find_by(name: 'still_image')
          when 'http://ndl.go.jp/ndltype/Photograph'
            content_type = ContentType.find_by(name: 'still_image')
          when 'http://ndl.go.jp/ndltype/PicturePostcard'
            content_type = ContentType.find_by(name: 'still_image')
          when 'http://purl.org/dc/dcmitype/MovingImage'
            content_type = ContentType.find_by(name: 'two_dimensional_moving_image')
          when 'http://purl.org/dc/dcmitype/Sound'
            content_type = ContentType.find_by(name: 'sounds')
          when 'http://purl.org/dc/dcmitype/StillImage'
            content_type = ContentType.find_by(name: 'still_image')
          end

          # NDLサーチのmaterialTypeは複数設定されているが、
          # content_typeはその最初の1件を用いて取得する
          break if content_type
        end

        admin_identifier = doc.at('//dcndl:BibAdminResource[@rdf:about]').attributes['about'].value
        description = doc.at('//dcterms:abstract').try(:content)
        price = doc.at('//dcndl:price').try(:content)
        volume_number_string = doc.at('//dcndl:volume/rdf:Description/rdf:value').try(:content)
        extent = get_extent(doc)
        publication_periodicity = doc.at('//dcndl:publicationPeriodicity').try(:content)
        statement_of_responsibility = doc.xpath('//dcndl:BibResource/dc:creator').map(&:content).join('; ')
        publication_place = doc.at('//dcterms:publisher/foaf:Agent/dcndl:location').try(:content)
        edition_string = doc.at('//dcndl:edition').try(:content)

        manifestation = Manifestation.find_by(manifestation_identifier: admin_identifier)
        return manifestation if manifestation

        Agent.transaction do
          publisher_agents = Agent.import_agents(publishers)

          manifestation = Manifestation.new(
            manifestation_identifier: admin_identifier,
            original_title: title[:manifestation],
            title_transcription: title[:transcription],
            title_alternative: title[:alternative],
            title_alternative_transcription: title[:alternative_transcription],
            # TODO: NDLサーチに入っている図書以外の資料を調べる
            #:carrier_type_id => CarrierType.find_by(name: 'print').id,
            language_id: language_id,
            pub_date: date,
            description: description,
            volume_number_string: volume_number_string,
            price: price,
            statement_of_responsibility: statement_of_responsibility,
            start_page: extent[:start_page],
            end_page: extent[:end_page],
            height: extent[:height],
            extent: extent[:extent],
            dimensions: extent[:dimensions],
            publication_place: publication_place,
            edition_string: edition_string
          )
          manifestation.serial = true if is_serial
          identifier = {}
          if isbn
            identifier[:isbn] = Identifier.new(body: isbn)
            identifier[:isbn].identifier_type = IdentifierType.find_by(name: 'isbn') || IdentifierType.create!(name: 'isbn')
          end
          if iss_itemno
            identifier[:iss_itemno] = Identifier.new(body: iss_itemno)
            identifier[:iss_itemno].identifier_type = IdentifierType.find_by(name: 'iss_itemno') || IdentifierType.create!(name: 'iss_itemno')
          end
          if jpno
            identifier[:jpno] = Identifier.new(body: jpno)
            identifier[:jpno].identifier_type = IdentifierType.find_or_create_by!(name: 'jpno')
          end
          if issn
            identifier[:issn] = Identifier.new(body: issn)
            identifier[:issn].identifier_type = IdentifierType.find_or_create_by!(name: 'issn')
          end
          if issn_l
            identifier[:issn_l] = Identifier.new(body: issn_l)
            identifier[:issn_l].identifier_type = IdentifierType.find_or_create_by!(name: 'issn_l')
          end
          manifestation.carrier_type = carrier_type if carrier_type
          manifestation.manifestation_content_type = content_type if content_type
          if manifestation.save
            identifier.each do |_k, v|
              manifestation.identifiers << v if v.valid?
            end
            manifestation.publishers << publisher_agents
            create_additional_attributes(doc, manifestation)
            if is_serial
              series_statement = SeriesStatement.new(
                original_title: title[:manifestation],
                title_alternative: title[:alternative],
                title_transcription: title[:transcription],
                series_master: true
              )
              if series_statement.valid?
                manifestation.series_statements << series_statement
              end
            else
              create_series_statement(doc, manifestation)
            end
          end
        end

        # manifestation.send_later(:create_frbr_instance, doc.to_s)
        manifestation
      end

      def create_additional_attributes(doc, manifestation)
        title = get_title(doc)
        creators = get_creators(doc).uniq
        subjects = get_subjects(doc).uniq
        classifications = get_classifications(doc).uniq
        classification_urls = doc.xpath('//dcterms:subject[@rdf:resource]').map { |subject| subject.attributes['resource'].value }

        Agent.transaction do
          creator_agents = Agent.import_agents(creators)
          content_type_id = begin
                              ContentType.find_by(name: 'text').id
                            rescue StandardError
                              1
                            end
          manifestation.creators << creator_agents

          if defined?(EnjuSubject)
            subject_heading_type = SubjectHeadingType.find_or_create_by!(name: 'ndlsh')
            subjects.each do |term|
              subject = Subject.find_by(term: term[:term])
              unless subject
                subject = Subject.new(term)
                subject.subject_heading_type = subject_heading_type
                subject.subject_type = SubjectType.find_or_create_by!(name: 'concept')
              end
              # if subject.valid?
              manifestation.subjects << subject
              # end
              # subject.save!
            end
            if classification_urls
              classification_urls.each do |url|
                begin
                  ndc_url = URI.parse(url)
                rescue URI::InvalidURIError
                end
                next unless ndc_url

                ndc_type = ndc_url.path.split('/').reverse[1]
                next unless (ndc_type == 'ndc9') || (ndc_type == 'ndc10')

                ndc = ndc_url.path.split('/').last
                classification_type = ClassificationType.find_or_create_by!(name: ndc_type)
                classification = Classification.new(category: ndc)
                classification.classification_type = classification_type
                manifestation.classifications << classification if classification.valid?
              end
            end
            ndc8 = doc.xpath('//dc:subject[@rdf:datatype="http://ndl.go.jp/dcndl/terms/NDC8"]').first
            if ndc8
              classification_type = ClassificationType.find_or_create_by!(name: 'ndc8')
              classification = Classification.new(category: ndc8.content)
              classification.classification_type = classification_type
              manifestation.classifications << classification if classification.valid?
            end
          end
        end
      end

      def search_ndl(query, options = {})
        options = { dpid: 'iss-ndl-opac', item: 'any', idx: 1, per_page: 10, raw: false, mediatype: 'books' }.merge(options)
        doc = nil
        results = {}
        startrecord = options[:idx].to_i
        startrecord = 1 if startrecord == 0
        url = "https://ndlsearch.ndl.go.jp/api/opensearch?dpid=#{options[:dpid]}&#{options[:item]}=#{format_query(query)}&cnt=#{options[:per_page]}&idx=#{startrecord}&mediatype=#{options[:mediatype]}"

        if options[:raw] == true
          URI.parse(url).read
        else
          RSS::Rss::Channel.install_text_element('openSearch:totalResults', 'http://a9.com/-/spec/opensearchrss/1.0/', '?', 'totalResults', :text, 'openSearch:totalResults')
          RSS::BaseListener.install_get_text_element 'http://a9.com/-/spec/opensearchrss/1.0/', 'totalResults', 'totalResults='
          RSS::Parser.parse(url, false)
        end
      end

      def normalize_isbn(isbn)
        if isbn.length == 10
          Lisbn.new(isbn).isbn13
        else
          Lisbn.new(isbn).isbn10
        end
      end

      def return_xml(isbn: nil, jpno: nil)
        if jpno.present?
          url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&version=1.2&query=jpno=#{jpno}&recordSchema=dcndl&onlyBib=true"
        elsif isbn.present?
          url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&version=1.2&query=isbn=#{isbn}&recordSchema=dcndl&onlyBib=true"
        else
          return
        end

        response = Nokogiri::XML(URI.parse(url).read).at('//xmlns:recordData')&.content

        Nokogiri::XML(response) if response
      end

      private

      def get_title(doc)
        title = {
          manifestation: doc.xpath('//dc:title/rdf:Description/rdf:value').collect(&:content).join(' '),
          transcription: doc.xpath('//dc:title/rdf:Description/dcndl:transcription').collect(&:content).join(' '),
          alternative: doc.at('//dcndl:alternative/rdf:Description/rdf:value').try(:content),
          alternative_transcription: doc.at('//dcndl:alternative/rdf:Description/dcndl:transcription').try(:content)
        }
        volumeTitle = doc.at('//dcndl:volumeTitle/rdf:Description/rdf:value').try(:content)
        volumeTitle_transcription = doc.at('//dcndl:volumeTitle/rdf:Description/dcndl:transcription').try(:content)
        title[:manifestation] << " #{volumeTitle}" if volumeTitle
        title[:transcription] << " #{volumeTitle_transcription}" if volumeTitle_transcription
        title
      end

      def get_creators(doc)
        creators = []
        doc.xpath('//dcterms:creator/foaf:Agent').each do |creator|
          creators << {
            full_name: creator.at('./foaf:name').content,
            full_name_transcription: creator.at('./dcndl:transcription').try(:content),
            agent_identifier: creator.attributes['about'].try(:content)
          }
        end
        creators
      end

      def get_subjects(doc)
        subjects = []
        doc.xpath('//dcterms:subject/rdf:Description').each do |subject|
          subjects << {
            term: subject.at('./rdf:value').content,
            #:url => subject.attribute('about').try(:content)
          }
        end
        subjects
      end

      def get_classifications(doc)
        classifications = []
        doc.xpath('//dcterms:subject[@rdf:resource]').each do |classification|
          classifications << {
            url: classification.attributes['resource'].content
          }
        end
        classifications
      end

      def get_language(doc)
        # TODO: 言語が複数ある場合
        language = doc.at('//dcterms:language[@rdf:datatype="http://purl.org/dc/terms/ISO639-2"]').try(:content)
        language.downcase if language
      end

      def get_publishers(doc)
        publishers = []
        doc.xpath('//dcterms:publisher/foaf:Agent').each do |publisher|
          publishers << {
            full_name: publisher.at('./foaf:name').content,
            full_name_transcription: publisher.at('./dcndl:transcription').try(:content),
            agent_identifier: publisher.attributes['about'].try(:content)
          }
        end
        publishers
      end

      def get_extent(doc)
        extent = doc.at('//dcterms:extent').try(:content)
        value = { start_page: nil, end_page: nil, height: nil }
        if extent
          extent = extent.split(';')
          page = extent[0].try(:strip)
          value[:extent] = page
          if page =~ /\d+p/
            value[:start_page] = 1
            value[:end_page] = page.to_i
          end
          height = extent[1].try(:strip)
          value[:dimensions] = height
          value[:height] = height.to_i if height =~ /\d+cm/
        end
        value
      end

      def create_series_statement(doc, manifestation)
        series = series_title = {}
        series[:title] = doc.at('//dcndl:seriesTitle/rdf:Description/rdf:value').try(:content)
        series[:title_transcription] = doc.at('//dcndl:seriesTitle/rdf:Description/dcndl:transcription').try(:content)
        series[:creator] = doc.at('//dcndl:seriesCreator').try(:content)
        if series[:title]
          series_title[:title] = series[:title].split(';')[0].strip
          if series[:title_transcription]
            series_title[:title_transcription] = series[:title_transcription].split(';')[0].strip
          end
        end

        if series_title[:title]
          series_statement = SeriesStatement.find_by(original_title: series_title[:title])
          series_statement ||= SeriesStatement.new(
            original_title: series_title[:title],
            title_transcription: series_title[:title_transcription],
            creator_string: series[:creator]
          )
        end

        if series_statement.try(:save)
          manifestation.series_statements << series_statement
        end
        manifestation
      end

      def format_query(query)
        Addressable::URI.encode(query.to_s.tr('　', ' '))
      end
    end

    class AlreadyImported < StandardError
    end
  end

  class RecordNotFound < StandardError
  end

  class InvalidIsbn < StandardError
  end
end
