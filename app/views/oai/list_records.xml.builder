xml.instruct! :xml, version: "1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request oai_provider_url(format: :xml), request_attr(@from_time, @until_time, @oai[:metadataPrefix])
  @oai[:errors].each do |error|
    xml.error code: error
  end
  xml.ListRecords do
    @manifestations.each do |manifestation|
      xml.record do
        xml.header do
          xml.identifier manifestation.oai_identifier
          xml.datestamp manifestation.updated_at.utc.iso8601
        end
        xml.metadata do
          case @oai[:metadataPrefix]
          when 'oai_dc', nil
            render 'record_oai_dc', manifestation: manifestation, xml_builder: xml
          when 'junii2'
            render 'record_junii2', manifestation: manifestation, xml_builder: xml
          when 'jpcoar'
            render 'record_jpcoar', manifestation: manifestation, xml_builder: xml
          when 'dcndl'
            render 'record_dcndl', manifestation: manifestation, xml_builder: xml
          end
        end
      end
    end
    if @manifestations.next_page_cursor
      xml.resumptionToken CGI.escape(@manifestations.next_page_cursor), completeListSize: @manifestations.total_count
    else
      xml.resumptionToken nil, completeListSize: @manifestations.total_count
    end
  end
end
