xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    if @user
      xml.title "#{@user.username}'s orders at #{@library_group.display_name.localize}"
      xml.link user_orders_url(@user.username)
      xml.tag! "atom:link", :rel => 'self', :href => user_orders_url(@user.username, :format => :rss)
      xml.tag! "atom:link", :rel => 'alternate', :href => user_orders_url(@user.username)
    else
      xml.title "Orders at #{@library_group.display_name.localize}"
      xml.link orders_url
      xml.tag! "atom:link", :rel => 'self', :href => orders_url(:format => :rss)
      xml.tag! "atom:link", :rel => 'alternate', :href => orders_url
    end
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @orders.offset + 1
      xml.tag! "opensearch:itemsPerPage", @orders.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    for order in @orders
      xml.item do
        xml.title order.order_list.title
        #xml.description(order.title)
        # rfc822
        xml.pubDate order.created_at.utc.iso8601
        xml.link order_url(order)
        xml.guid order_url(order), :isPermaLink => "true"
      end
    end
  }
}
