xml.instruct! :xml, :version=>"1.0"
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    if @user
      xml.title t('checkout.user_checkout', :login_name => @user.username)
      xml.link user_checkouts_url(@user)
      xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => :rss))}"
      xml.tag! "atom:link", :rel => 'alternate', :href => user_checkouts_url(@user)
    else
      xml.title t('checkout.library_group_checkout', :library_group_name => @library_group.display_name.localize)
      xml.link checkouts_url
      xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => :rss))}"
      xml.tag! "atom:link", :rel => 'alternate', :href => checkouts_url
    end
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale.to_s
    xml.ttl "60"
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @checkouts.offset + 1
      xml.tag! "opensearch:itemsPerPage", @checkouts.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    @checkouts.each do |checkout|
      xml.item do
        xml.title checkout.item.manifestation.original_title
        #xml.description(checkout.title)
        # rfc822
        xml.pubDate checkout.created_at.utc.rfc822
        xml.link user_checkout_url(checkout.user, checkout)
        xml.guid user_checkout_url(checkout.user, checkout), :isPermaLink => "true"
      end
    end
  }
}
