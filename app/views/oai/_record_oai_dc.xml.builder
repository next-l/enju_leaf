xml_builder.tag! "oai_dc:dc",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd",
  "xmlns:oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml_builder.tag! "dc:title", manifestation.original_title
  manifestation.creators.readable_by(current_user).each do |patron|
    xml_builder.tag! "dc:creator", patron.full_name
  end
  manifestation.contributors.readable_by(current_user).each do |patron|
    xml_builder.tag! "dc:contributor", patron.full_name
  end
  manifestation.publishers.readable_by(current_user).each do |patron|
    xml_builder.tag! "dc:publisher", patron.full_name
  end
  manifestation.try(:subjects).try(:each) do |subject|
    xml_builder.tag! "dc:subject", subject.term
  end
  xml_builder.tag! "dc:description", manifestation.description
  xml_builder.tag! "dc:date", manifestation.pub_date
end
