xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('inter_library_loan.library_group_inter_library_loan', :library_group_name => @library_group.display_name.localize)
    xml.link inter_library_loans_url
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => inter_library_loans_url(:format => :rss)
    xml.tag! "atom:link", :rel => 'alternate', :href => inter_library_loans_url
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    #unless params[:query].blank?
    #  xml.tag! "opensearch:totalResults", @count[:query_result]
    #  xml.tag! "opensearch:startIndex", @inter_library_loans.offset + 1
    #  xml.tag! "opensearch:itemsPerPage", @inter_library_loans.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    #end
    for inter_library_loan in @inter_library_loans
      xml.item do
        xml.title h(inter_library_loan.item.manifestation.original_title)
        #xml.description(inter_library_loan.title)
        # rfc822
        xml.pubDate inter_library_loan.created_at.utc.iso8601
        xml.link inter_library_loan_url(inter_library_loan)
        xml.guid inter_library_loan_url(inter_library_loan), :isPermaLink => "true"
      end
    end
  }
}
