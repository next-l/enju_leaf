xml.dcndl :BibResource do
  xml.rdf :Description, 'rdf:about' => manifestation_url(manifestation) do
    if manifestation.nbn?
      xml.dcterms :identifier, manifestation.nbn, 'rdf:datatype' => 'http://ndl.go.jp/dcndl/terms/JPNO'
      xml.rdfs :seeAlso, 'rdf:resource' => "http://id.ndl.go.jp/jpno/#{manifestation.nbn}"
    end
    if manifestation.isbn?
      xml.dcterms :identifier, manifestation.isbn, 'rdf:datatype' => 'http://ndl.go.jp/dcndl/terms/ISBN'
      xml.rdfs :seeAlso, 'rdf:resource' => "http://iss.ndl.go.jp/isbn/#{manifestation.isbn}"
    end
    xml.dcterms :title, manifestation.original_title
    xml.dc :title do
      xml.rdf :Description do
        xml.rdf :value, manifestation.original_title
        xml.dcndl :transcription, manifestation.title_transcription
      end
    end
    if manifestation.title_alternative
      xml.dcndl :alternative do
        xml.rdf :Description do
          xml.rdf :value, manifestation.title_alternative
        end
      end
    end
    if manifestation.volume_number_string?
      xml.dcndl :volume do
        xml.rdf :Description do
          xml.rdf :value, manifestation.volume_number_string
        end
      end
    end
    if manifestation.edition_string?
      xml.dcndl :edition do
        xml.rdf :Description do
          xml.rdf :value, manifestation.edition_string
        end
      end
    end
    manifestation.creators.each do |creator|
      xml.dcterms :creator do
        xml.foaf :Agent do
          xml.foaf :name, creator.full_name
          xml.dcndl :transcription, creator.full_name_transcription
        end
      end
      xml.dc :creator, creator.full_name
    end
    manifestation.publishers.each do |publisher|
      xml.dcterms :publisher do
        xml.foaf :Agent do
          xml.foaf :name, publisher.full_name
          xml.dcndl :transcription, publisher.full_name_transcription
          xml.dcndl :location, publisher.address_1
        end
      end
      xml.dcndl :publicationPlace, publisher.country.alpha_2.downcase, 'rdf:datatype' => 'http://purl.org/dc/terms/ISO3166'
    end
    xml.dcterms :language, manifestation.language.iso_639_2, 'rdf:datatype' => "http://purl.org/dc/terms/ISO639-2" if manifestation.language
    xml.dcterms :date, manifestation.pub_date
    xml.dcterms :issued, manifestation.date_of_publication.try(:year), 'rdf:datatype' => "http://purl.org/dc/terms/W3CDTF"
    xml.dcndl :price, manifestation.price
  end
end
