xml.instruct! :xml, version: "1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request oai_provider_url(format: :xml), verb: "ListSets"
  xml.ListSets do
    @series_statements.each do |series_statement|
      xml.set do
        xml.setSpec series_statement.id
        xml.setName series_statement.original_title
      end
    end

    if @series_statements.next_page_cursor
      xml.resumptionToken CGI.escape(@series_statements.next_page_cursor), completeListSize: @series_statements.total_count
    else
      xml.resumptionToken nil, completeListSize: @series_statements.total_count
    end
  end
end
