xml_builder.tag! "rdf:RDF",
  "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  "xmlns:dcterms" => "http://purl.org/dc/terms/",
  "xmlns:dcndl" => "http://ndl.go.jp/dcndl/terms/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  "xmlns:rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
  "xmlns:owl" => "http://www.w3.org/2002/07/owl#",
  "xmlns:foaf" => "http://xmlns.com/foaf/0.1/" do
  get_record_url = oai_provider_url format: "xml", verb: 'GetRecord', metadataPrefix: 'dcndl', identifier: manifestation.oai_identifier
  xml_builder.tag! "dcndl:BibAdminResource", "rdf:about" => get_record_url do
    xml_builder.tag! "dcndl:record", "rdf:resource" => get_record_url + "#material"
    xml_builder.tag! "dcndl:bibRecordCategory", ENV['DCNDL_BIBRECORDCATEGORY']
  end
  xml_builder.tag! "dcndl:BibResource", "rdf:about" => get_record_url + "#material" do
    xml_builder.tag! "rdfs:seeAlso", "rdf:resource" => manifestation_url(manifestation)
    manifestation.identifiers.each do |identifier|
      case identifier.identifier_type.try(:name)
      when 'isbn'
        xml_builder.tag! "rdfs:seeAlso", "rdf:resource" => "http://iss.ndl.go.jp/isbn/#{ identifier.body }"
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/ISBN"
      when 'issn'
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/ISSN"
      when 'doi'
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/DOI"
      when 'ncid'
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/NIIBibID"
      end
    end
    xml_builder.tag! "dcterms:title", manifestation.original_title
    xml_builder.tag! "dc:title" do
      xml_builder.tag! "rdf:Description" do
        xml_builder.tag! "rdf:value", manifestation.original_title
        if manifestation.title_transcription?
          xml_builder.tag! "dcndl:transcription", manifestation.title_transcription
        end
      end
    end
    if manifestation.title_alternative?
      xml_builder.tag! "dcndl:alternative" do
        xml_builder.tag! "rdf:Description" do
          xml_builder.tag! "rdf:value", manifestation.title_alternative
          if manifestation.title_alternative_transcription?
            xml_builder.tag! "dcndl:transcription", manifestation.title_alternative_transcription
          end
        end
      end
    end
    if manifestation.volume_number_string?
      xml_builder.tag! "dcndl:volume" do
        xml_builder.tag! "rdf:Description" do
          xml_builder.tag! "rdf:value", manifestation.volume_number_string
        end
      end
    elsif manifestation.volume_number?
      xml_builder.tag! "dcndl:volume" do
        xml_builder.tag! "rdf:Description" do
          xml_builder.tag! "rdf:value", manifestation.volume_number
        end
      end
    end
    manifestation.series_statements.each do |series_statement|
      xml_builder.tag! "dcndl:seriesTitle" do
        xml_builder.tag! "rdf:Description" do
          xml_builder.tag! "rdf:value", series_statement.original_title
          if series_statement.title_transcription?
            xml_builder.tag! "dcndl:transcription", series_statement.title_transcription
          end
        end
      end
    end
    if manifestation.edition_string?
      xml_builder.tag! "dcndl:edition", manifestation.edition_string
    elsif manifestation.edition?
      xml_builder.tag! "dcndl:edition", manifestation.edition
    end
    unless manifestation.creators.empty?
      manifestation.creators.each do |creator|
        xml_builder.tag! "dcterms:creator" do
          xml_builder.tag! "foaf:Agent" do
            xml_builder.tag! "foaf:name", creator.full_name
            if creator.full_name_transcription?
              xml_builder.tag! "dcndl:transcription", creator.full_name_transcription
            end
          end
        end
      end
    end
    xml_builder.tag! "dc:creator", manifestation.statement_of_responsibility if manifestation.statement_of_responsibility.present?
    manifestation.series_statements.each do |series_statement|
      xml_builder.tag! "dcndl:seriesCreator", series_statement.creator_string
    end
    manifestation.contributors.each do |contributor|
      xml_builder.tag! "dcndl:contributor", contributor.full_name
    end
    manifestation.publishers.each do |publisher|
      xml_builder.tag! "dcterms:publisher" do
        xml_builder.tag! "foaf:Agent" do
          if publisher.corporate_name
            xml_builder.tag! "foaf:name", publisher.corporate_name
            xml_builder.tag! "dcndl:transcription", publisher.corporate_name_transcription if publisher.corporate_name_transcription?
          elsif publisher.full_name
            xml_builder.tag! "foaf:name", publisher.full_name
            xml_builder.tag! "dcndl:transcription", publisher.full_name_transcription if publisher.full_name_transcription?
          end
          xml_builder.tag! "dcterms:description", publisher.note if publisher.note?
          xml_builder.tag! "dcndl:location", publisher.place if publisher.place?
        end
      end
    end
    manifestation.publishers.each do |publisher|
      xml_builder.tag! "dcndl:publicationPlace", publisher.country.alpha_2 if publisher.country.try(:name) != "unknown"
    end
    xml_builder.tag! "dcterms:issued", manifestation.pub_date, "rdf:datatype" => "http://purl.org/dc/terms/W3CDTF" if manifestation.pub_date?
    xml_builder.tag! "dcterms:description", manifestation.description if manifestation.description?
    manifestation.subjects.each do |subject|
      xml_builder.tag! "dcterms:subject" do
        xml_builder.tag! "rdf:Description" do
          xml_builder.tag! "rdf:value", subject.term
          xml_builder.tag! "dcndl:transcription", subject.term_transcription if subject.term_transcription?
        end
      end
    end
    manifestation.classifications.each do |classification|
      case classification.classification_type.name
      when 'ndlc'
        xml_builder.tag! "dcterms:subject", "rdf:resource" => "http://id.ndl.go.jp/class/ndlc/"+classification.category
      when 'ndc9'
        xml_builder.tag! "dcterms:subject", "rdf:resource" => "http://id.ndl.go.jp/class/ndc9/"+classification.category
      when 'ddc'
        xml_builder.tag! "dcterms:subject", "rdf:resource" => "http://dewey.info/class/"+classification.category
      when 'ndc8'
        xml_builder.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/NDC8"
      when 'ndc'
        xml_builder.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/NDC"
      when 'lcc'
        xml_builder.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/LCC"
      when 'udc'
        xml_builder.tag! "dc:subject", classification.category, "rdf:datatype" => "http://ndl.go.jp/dcndl/terms/UDC"
      end
    end
    xml_builder.tag! "dcterms:language", manifestation.language.iso_639_2, "rdf:datatype" => "http://purl.org/dc/terms/ISO639-2"
    xml_builder.tag! "dcndl:price", manifestation.price if manifestation.price?
    if manifestation.extent? or manifestation.dimensions?
      xml_builder.tag! "dcterms:extent", [ manifestation.extent, manifestation.dimensions ].compact.join(" ; ")
    end
    material_type = nil
    case manifestation.carrier_type.name
    when "volume"
      material_type = :book
    when "online_resource"
      material_type = :electronic_resource
    end
    case manifestation.manifestation_content_type&.name
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
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Book", "rdfs:label" => "図書"
    when :electronic_resource
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/ElectronicResource", "rdfs:label" => "電子資料"
    when :braille
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Braille", "rdfs:label" => "点字"
    when :map
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Map", "rdfs:label" => "地図"
    when :music
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/Music", "rdfs:label" => "音楽"
    when :music_score
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://ndl.go.jp/ndltype/MusicScore", "rdfs:label" => "楽譜"
    when :still_image
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://purl.org/dc/dcmitype/StillImage", "rdfs:label" => "静止画資料"
    when :moving_image
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://purl.org/dc/dcmitype/MovingImage", "rdfs:label" => "映像資料"
    when :sound
      xml_builder.tag! "dcndl:materialType", "rdf:resource" => "http://purl.org/dc/dcmitype/Sound", "rdfs:label" => "録音資料"
    end
    if manifestation.serial && manifestation.frequency
      xml_builder.tag! "dcndl:publicationPeriodicity", manifestation.frequency.name
    end
  end
end
