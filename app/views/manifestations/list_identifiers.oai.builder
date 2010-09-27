xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request manifestations_url(:format => :oai), :verb => "ListIdentifiers", :metadataPrefix => "oai_dc"
  @oai[:errors].each do |error|
    xml.error :code => error
  end
  xml.ListIdentifiers do
    @manifestations.each do |manifestation|
      cache(:controller => :manifestations, :action => :show, :id => manifestation.id, :page => 'oai_pmh_list_identifiers', :role => current_user_role_name, :locale => @locale) do
        xml.header do
          xml.identifier manifestation.oai_identifier
          xml.datestamp manifestation.updated_at.utc.iso8601
          xml.setSpec manifestation.series_statement.id if manifestation.series_statement
        end
      end
    end
    if @resumption.present?
      if @resumption[:cursor].to_i + @manifestations.per_page < @manifestations.total_entries
        xml.resumptionToken @resumption[:token], :completeListSize => @manifestations.total_entries, :cursor => @resumption[:cursor], :expirationDate => @resumption[:expired_at]
      end
    end
  end
end
