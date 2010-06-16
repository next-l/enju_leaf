xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    if @user
      xml.title t('purchase_request.user_purchase_request', :login_name => @user.username)
      xml.link user_purchase_requests_url(@user.username)
      xml.tag! "atom:link", :rel => 'self', :href => user_purchase_requests_url(@user.username, :format => "rss")
      xml.tag! "atom:link", :rel => 'alternate', :href => user_purchase_requests_url(@user.username)
    else
      xml.title t('purchase_request.library_group_purchase_request', :library_group_name => @library_group.display_name.localize)
      xml.link purchase_requests_url
      xml.tag! "atom:link", :rel => 'self', :href => purchase_requests_url(:format => "rss")
      xml.tag! "atom:link", :rel => 'alternate', :href => purchase_requests_url
    end
    xml.language @locale
    xml.ttl "60"
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @purchase_requests.offset + 1
      xml.tag! "opensearch:itemsPerPage", @purchase_requests.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    @purchase_requests.each do |purchase_request|
      xml.item do
        xml.title purchase_request.title
        #xml.description(purchase_request.title)
        # rfc822
        xml.pubDate purchase_request.created_at.utc.iso8601
        xml.link user_purchase_request_url(purchase_request.user.username, purchase_request)
        xml.guid user_purchase_request_url(purchase_request.user.username, purchase_request), :isPermaLink => "true"
      end
    end
  }
}
