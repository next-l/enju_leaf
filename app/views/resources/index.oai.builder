xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH",
  :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request resources_url(:format => :oai)
  @oai[:errors].each do |error|
    xml.error :code => error
  end
end
