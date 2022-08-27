module EnjuOai
  module OaiModel
    extend ActiveSupport::Concern
    OAI::Provider::Base.register_format(EnjuOai::Jpcoar.instance)
    OAI::Provider::Base.register_format(EnjuOai::Junii2.instance)
    OAI::Provider::Base.register_format(EnjuOai::Dcndl.instance)

    def to_oai_dc
      xml = Builder::XmlMarkup.new
      xml.tag!("oai_dc:dc",
        'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>
          %{http://www.openarchives.org/OAI/2.0/oai_dc/
            http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
        xml.tag! 'dc:title', original_title
        creators.readable_by(nil).each do |creator|
          xml.tag! 'dc:creator', creator.full_name
        end
        subjects.each do |subject|
          xml.tag! 'dc:subject', subject.term
        end
        xml.tag! 'dc:description', description
      end

      xml.target!
    end

    def to_jpcoar
      xml = Builder::XmlMarkup.new
      xml.tag!('jpcoar:jpcoar', "xsi:schemaLocation" => "https://github.com/JPCOAR/schema/blob/master/1.0/jpcoar_scm.xsd",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:rioxxterms" => "http://www.rioxx.net/schema/v2.0/rioxxterms/",
        "xmlns:datacite" => "https://schema.datacite.org/meta/kernel-4/",
        "xmlns:oaire" => "http://namespace.openaire.eu/schema/oaire/",
        "xmlns:dcndl" => "http://ndl.go.jp/dcndl/terms/",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:jpcoar" => "https://github.com/JPCOAR/schema/blob/master/1.0/") do
        xml.tag! 'dc:title', original_title
        xml.tag! 'dc:language', language.iso_639_2
        xml.creators do
          creators.readable_by(nil).each do |creator|
            xml.creatorName creator.full_name
          end
        end

        subjects.each do |subject|
          xml.tag! 'jpcoar:subject', subject.term
        end

        if attachment
          xml.tag! 'jpcoar:file' do
            xml.tag! 'jpcoar:URI', URI.join(ENV['ENJU_LEAF_BASE_URL'], "/manifestations/#{id}?format=download")
          end
        end
      end

      xml.target!
    end

    def to_dcndl
      xml = Builder::XmlMarkup.new
      xml.tag! "rdf:RDF",
        "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dcndl" => "http://ndl.go.jp/dcndl/terms/",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
        "xmlns:owl" => "http://www.w3.org/2002/07/owl#",
        "xmlns:foaf" => "http://xmlns.com/foaf/0.1/" do
        get_record_url = URI.join(ENV['ENJU_LEAF_BASE_URL'], "/oai?verb=GetRecord&metadataPrefix=dcndl&identifier=#{oai_identifier}")
        xml.tag! "dcndl:BibAdminResource", "rdf:about" => get_record_url do
          xml.tag! "dcndl:record", "rdf:resource" => get_record_url + "#material"
          xml.tag! "dcndl:bibRecordCategory", ENV['DCNDL_BIBRECORDCATEGORY']
        end
        xml.tag! "dcndl:BibResource", "rdf:about" => get_record_url + "#material" do
          xml.tag! "rdfs:seeAlso", "rdf:resource" => URI.join(ENV['ENJU_LEAF_BASE_URL'], "/manifestations/#{id}")
          identifiers.each do |identifier|
            case identifier.identifier_type.try(:name)
            when 'isbn'
              xml.tag! "rdfs:seeAlso", "rdf:resource" => "http://iss.ndl.go.jp/isbn/#{identifier.body}"
              xml.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/ISBN"
            when 'issn'
              xml.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/ISSN"
            when 'doi'
              xml.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/DOI"
            when 'ncid'
              xml.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/NIIBibID"
            end
          end
          xml.tag! "dcterms:title", original_title
          xml.tag! "dc:title" do
            xml.tag! "rdf:Description" do
              xml.tag! "rdf:value", original_title
              if title_transcription?
                xml.tag! "dcndl:transcription", title_transcription
              end
            end
          end
          if title_alternative?
            xml.tag! "dcndl:alternative" do
              xml.tag! "rdf:Description" do
                xml.tag! "rdf:value", title_alternative
                if title_alternative_transcription?
                  xml.tag! "dcndl:transcription", title_alternative_transcription
                end
              end
            end
          end
          if volume_number_string?
            xml.tag! "dcndl:volume" do
              xml.tag! "rdf:Description" do
                xml.tag! "rdf:value", volume_number_string
              end
            end
          elsif volume_number?
            xml.tag! "dcndl:volume" do
              xml.tag! "rdf:Description" do
                xml.tag! "rdf:value", volume_number
              end
            end
          end
          series_statements.each do |series_statement|
            xml.tag! "dcndl:seriesTitle" do
              xml.tag! "rdf:Description" do
                xml.tag! "rdf:value", series_statement.original_title
                if series_statement.title_transcription?
                  xml.tag! "dcndl:transcription", series_statement.title_transcription
                end
              end
            end
          end
          if edition_string?
            xml.tag! "dcndl:edition", edition_string
          elsif edition?
            xml.tag! "dcndl:edition", edition
          end
          unless creators.readable_by(nil).empty?
            creators.readable_by(nil).each do |creator|
              xml.tag! "dcterms:creator" do
                xml.tag! "foaf:Agent" do
                  xml.tag! "foaf:name", creator.full_name
                  if creator.full_name_transcription?
                    xml.tag! "dcndl:transcription", creator.full_name_transcription
                  end
                end
              end
            end
          end
          xml.tag! "dc:creator", statement_of_responsibility if statement_of_responsibility.present?
          series_statements.each do |series_statement|
            xml.tag! "dcndl:seriesCreator", series_statement.creator_string
          end
          contributors.readable_by(nil).each do |contributor|
            xml.tag! "dcndl:contributor", contributor.full_name
          end
          publishers.readable_by(nil).each do |publisher|
            xml.tag! "dcterms:publisher" do
              xml.tag! "foaf:Agent" do
                if publisher.corporate_name
                  xml.tag! "foaf:name", publisher.corporate_name
                  xml.tag! "dcndl:transcription", publisher.corporate_name_transcription if publisher.corporate_name_transcription?
                elsif publisher.full_name
                  xml.tag! "foaf:name", publisher.full_name
                  xml.tag! "dcndl:transcription", publisher.full_name_transcription if publisher.full_name_transcription?
                end
                xml.tag! "dcterms:description", publisher.note if publisher.note?
                xml.tag! "dcndl:location", publisher.place if publisher.place?
              end
            end
          end
          publishers.readable_by(nil).each do |publisher|
            xml.tag! "dcndl:publicationPlace", publisher.country.alpha_2 if publisher.country.try(:name) != "unknown"
          end
          xml.tag! "dcterms:issued", pub_date, "rdf:datatype" => "http://purl.org/dc/terms/W3CDTF" if pub_date?
          xml.tag! "dcterms:description", description if description?
          subjects.each do |subject|
            xml.tag! "dcterms:subject" do
              xml.tag! "rdf:Description" do
                xml.tag! "rdf:value", subject.term
                xml.tag! "dcndl:transcription", subject.term_transcription if subject.term_transcription?
              end
            end
          end
          classifications.each do |classification|
            case classification.classification_type.name
            when 'ndlc'
              xml.tag! "dcterms:subject", "rdf:resource" => "http://id.ndl.go.jp/class/ndlc/" + classification.category
            when 'ndc9'
              xml.tag! "dcterms:subject", "rdf:resource" => "http://id.ndl.go.jp/class/ndc9/" + classification.category
            when 'ddc'
              xml.tag! "dcterms:subject", "rdf:resource" => "http://dewey.info/class/" + classification.category
            when 'ndc8'
              xml.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/NDC8"
            when 'ndc'
              xml.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/NDC"
            when 'lcc'
              xml.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/LCC"
            when 'udc'
              xml.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/UDC"
            end
          end
          xml.tag! "dcterms:language", language.iso_639_2, "rdf:datatype" => "http://purl.org/dc/terms/ISO639-2"
          xml.tag! "dcndl:price", price if price?
          if extent? || dimensions?
            xml.tag! "dcterms:extent", [extent, dimensions].compact.join(" ; ")
          end
          material_type = nil
          case carrier_type.name
          when "volume"
            material_type = :book
          when "online_resource"
            material_type = :electronic_resource
          end
          case manifestation_content_type&.name
          when "text"
            material_type = :book
          when "tactile_text"
            material_type = :braille
          when "cartographic_image"
            material_type = :map
          when "performed_music"
            material_type = :music
          when "notated_music"
            material_type = :music_score
          when "still_image"
            material_type = :still_image
          when "two_dimensional_moving_image"
            material_type = :moving_image
          when "sounds"
            material_type = :sound
          end
          case material_type
          when :book
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Book", "rdfs:label" => "図書"
          when :electronic_resource
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/ElectronicResource", "rdfs:label" => "電子資料"
          when :braille
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Braille", "rdfs:label" => "点字"
          when :map
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Map", "rdfs:label" => "地図"
          when :music
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Music", "rdfs:label" => "音楽"
          when :music_score
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/MusicScore", "rdfs:label" => "楽譜"
          when :still_image
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://purl.org/dc/dcmitype/StillImage", "rdfs:label" => "静止画資料"
          when :moving_image
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://purl.org/dc/dcmitype/MovingImage", "rdfs:label" => "映像資料"
          when :sound
            xml.tag! "dcndl:materialType", "rdf:resource" => "http://purl.org/dc/dcmitype/Sound", "rdfs:label" => "録音資料"
          end
          if serial && frequency
            xml.tag! "dcndl:publicationPeriodicity", frequency.name
          end
        end
      end

      xml.target!
    end

    def to_junii2
      xml = Builder::XmlMarkup.new
      xml.junii2 :version => '3.1',
        "xsi:schemaLocation" => "http://irdb.nii.ac.jp/oai http://irdb.nii.ac.jp/oai/junii2-3-1.xsd",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns" => "http://irdb.nii.ac.jp/oai",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
        xml.title original_title
        xml.alternative title_alternative if title_alternative.present?

        creators.readable_by(nil).each do |patron|
          xml.creator patron.full_name
        end

        subjects.each do |subject|
          unless subject.subject_type.name =~ /BSH|NDLSH|MeSH|LCSH/io
            xml.subject subject.term
          end
        end

        if try(:classifications)
          %w[NDC NDLC].each do |c|
            classifications.each do |classification|
              if classification.classification_type.name =~ /#{c}/i
                xml.tag! c, classification.category
              end
            end
          end
        end

        if try(:subjects)
          %w[BSH NDLSH MeSH].each do |s|
            subjects.each do |subject|
              if subject.subject_type.name =~ /#{s}/i
                xml.tag! subject, subject.term
              end
            end
          end
        end

        if try(:classifications)
          %w[DDC LCC UDC].each do |c|
            classifications.each do |classification|
              if classification.classification_type.name =~ /#{c}/i
                xml.tag! c, classification.category
              end
            end
          end
        end

        subjects.each do |s|
          if s.subject_type.name =~ /LCSH/i
            xml.tag! subject, subject.term
          end
        end

        if description?
          xml.description description
        end
        publishers.readable_by(nil).each do |patron|
          xml.publisher patron.full_name
        end
        contributors.readable_by(nil).each do |patron|
          xml.contributor patron.full_name
        end
        xml.date created_at.to_date.iso8601
        xml.type manifestation_content_type&.name
        if try(:nii_type)
          xml.NIItype nii_type.name
        else
          xml.NIItype 'Others'
        end
        if attachment
          xml.format attachment.content_type
        end
        if manifestation_identifier?
          xml.identifier manifestation_identifier
        end
        identifiers.each do |identifier|
          unless identifier.identifier_type.name =~ /isbn|issn|ncid|doi|naid|pmid|ichushi/io
            xml.identifier identifier.body
          end
        end
        xml.URI URI.join(ENV['ENJU_LEAF_BASE_URL'], "/manifestations/#{id}")
        if attachment
          xml.fulltextURL URI.join(ENV['ENJU_LEAF_BASE_URL'], "/manifestations/#{id}?format=download")
        end
        %w[isbn issn NCID].each do |identifier|
          identifier_contents(identifier.downcase).each do |val|
            xml.tag! identifier, val
          end
        end
        if root_series_statement
          xml.jtitle root_series_statement.original_title
        end
        xml.volume volume_number_string
        xml.issue issue_number_string
        xml.spage start_page
        xml.epage end_page
        if pub_date?
          xml.dateofissued pub_date
        end
        # TODO: junii2: source
        if language.blank? || language.name == 'unknown'
          xml.language "und"
        else
          xml.language language.iso_639_2
        end
        %w[pmid doi NAID ichushi].each do |identifier|
          identifier_contents(identifier.downcase).each do |val|
            xml.tag! identifier, val
          end
        end
        # TODO: junii2: isVersionOf, hasVersion, isReplaceBy, replaces, isRequiredBy, requires, isPartOf, hasPart, isReferencedBy, references, isFormatOf, hasFormat
        # TODO: junii2: coverage, spatial, NIIspatial, temporal, NIItemporal
        # TODO: junii2: rights
        # TODO: junii2: textversion
        # TODO: junii2: grantid, dateofgranted, degreename, grantor
      end
    end

    def self.repository_url
      URI.join(ENV['ENJU_LEAF_BASE_URL'], '/oai')
    end

    def self.record_prefix
      "oai:#{URI.parse(ENV['ENJU_LEAF_BASE_URL']).host}:manifestations"
    end

    def oai_identifier
      [EnjuOai::OaiModel.record_prefix, id].join(':')
    end
  end
end
