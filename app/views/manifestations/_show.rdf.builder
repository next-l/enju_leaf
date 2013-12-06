  xml.rdf(:Description, 'rdf:about' => manifestation_url(manifestation)) do
    xml.title manifestation.original_title
    #xml.description(manifestation.original_title)
    xml.tag! 'dc:date', manifestation.created_at.utc.iso8601
    manifestation.creators.readable_by(current_user).each do |creator|
      xml.tag! 'foaf:maker' do
        xml.tag! 'foaf:Person' do
          xml.tag! 'foaf:name', creator.full_name
          xml.tag! 'foaf:name', creator.full_name_transcription if creator.full_name_transcription.present?
        end
      end
    end
    xml.tag! 'dc:creator' do
      xml.tag! 'rdf:Seq' do
        manifestation.creators.readable_by(current_user).each do |creator|
          xml.tag! 'rdf:li', creator.full_name
        end
      end
    end
    xml.tag! 'dc:creator' do
      xml.tag! 'rdf:Seq' do
        manifestation.contributors.readable_by(current_user).each do |contributor|
          xml.tag! 'rdf:li', contributor.full_name
        end
      end
    end
    xml.tag! 'dc:publisher' do
      xml.tag! 'rdf:Seq' do
        manifestation.publishers.readable_by(current_user).each do |publisher|
          xml.tag! 'rdf:li', publisher.full_name
        end
      end
    end
    xml.tag! 'dc:identifier', "urn:ISBN:#{manifestation.isbn}" if manifestation.isbn.present?
    xml.tag! 'dc:description', manifestation.description
    xml.link manifestation_url(manifestation)
    manifestation.subjects.each do |subject|
      xml.tag! "foaf:topic", "rdf:resource" => subject_url(subject)
    end
  end
