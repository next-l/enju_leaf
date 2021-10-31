xml.instruct! :xml, version: "1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request oai_provider_url(format: :xml), verb: "ListMetadataFormats"
  xml.ListMetadataFormats do
    xml.metadataFormat do
      xml.metadataPrefix "oai_dc"
      xml.schema "http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
      xml.metadataNamespace "http://www.openarchives.org/OAI/2.0/oai_dc/"
    end
    xml.metadataFormat do
      xml.metadataPrefix "junii2"
      xml.schema "http://irdb.nii.ac.jp/oai/junii2-3-1.xsd"
      xml.metadataNamespace "http://irdb.nii.ac.jp/oai"
    end
    xml.metadataFormat do
      xml.metadataPrefix "dcndl"
      xml.schema nil
      xml.metadataNamespace "http://ndl.go.jp/dcndl/terms/"
    end
  end
end
