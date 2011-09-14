xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request manifestations_url(:format => :oai), :verb => "Identify"
  xml.Identify do
    xml.repositoryName LibraryGroup.site_config.name
    xml.baseURL manifestations_url(:format => :oai)
    xml.protocolVersion "2.0"
    xml.adminEmail LibraryGroup.site_config.email
    xml.earliestDatestamp Manifestation.last.created_at.utc.iso8601 if Manifestation.last
    xml.deletedRecord "no"
    xml.granularity "YYYY-MM-DDThh:mm:ssZ"
  end
end
