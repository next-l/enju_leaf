xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    if @user
      xml.title t('reserve.user_reserve', :login_name => @user.username)
      xml.link user_reserves_url(@user.username, :format => :rss)
    else
      xml.title t('reserve.library_group_reserve', :library_group_name => @library_group.display_name.localize)
      xml.link reserves_url(:format => :rss)
    end
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    if @user
      xml.tag! "atom:link", :rel => 'self', :href => user_reserves_url(@user.username, :format => :rss)
      xml.tag! "atom:link", :rel => 'alternate', :href => user_reserves_url(@user.username)
    else
      xml.tag! "atom:link", :rel => 'self', :href => reserves_url(:format => :rss)
      xml.tag! "atom:link", :rel => 'alternate', :href => reserves_url
    end
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @reserves.offset + 1
      xml.tag! "opensearch:itemsPerPage", @reserves.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    for reservation in @reserves
      xml.item do
        xml.title reservation.manifestation.original_title
        #xml.description(reservation.title)
        # rfc822
        xml.pubDate reservation.created_at.utc.iso8601
        xml.link user_reserve_url(reservation.user.username, reservation)
        xml.guid user_reserve_url(reservation.user.username, reservation), :isPermaLink => "true"
      end
    end
  }
}
