xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request manifestations_url(:format => :oai), :verb => "ListMetadataFormats"
  xml.ListMetadataFormats do
    xml.metadataFormat do
      xml.metadataPrefix "oai_dc"
      xml.schema "http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
      xml.metadataNamespace "http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
    end
    #xml.metadataFormat do
    #  xml.metadataPrefix "junii2"
    #  xml.schema "http://ju.nii.ac.jp/oai/junii2.xsd"
    #  xml.metadataNamespace "http://ju.nii.ac.jp/junii2"
    #end
  end
end
