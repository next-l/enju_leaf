xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('order_list.library_group_order_list', :library_group_name => @library_group.display_name.localize)
    xml.link order_lists_url
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => order_lists_url(:format => "rss")
    xml.tag! "atom:link", :rel => 'alternate', :href => order_lists_url
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @order_lists.offset + 1
      xml.tag! "opensearch:itemsPerPage", @order_lists.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    for order_list in @order_lists
      xml.item do
        xml.title order_list.title
        #xml.description(order_list.title)
        # rfc822
        xml.pubDate order_list.created_at.utc.iso8601
        xml.link order_list_url(order_list)
        xml.guid order_list_url(order_list), :isPermaLink => "true"
      end
    end
  }
}
