xml.instruct! :xml, :version=>"1.0"
xml.rss('version' => "2.0",
        'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
        'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('patron.library_group_patron', :library_group_name => @library_group.display_name.localize)
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => nil))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale.to_s
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => :rss))}"
    xml.tag! "atom:link", :rel => 'alternate', :href => patrons_url
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => page_opensearch_url
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @patrons.offset + 1
      xml.tag! "opensearch:itemsPerPage", @patrons.per_page
      xml.tag! "opensearch:Query", :role => 'request', :searchTerms => h(params[:query]), :startPage => (h(params[:page]) || 1)
    end
    @patrons.each do |patron|
      xml.item do
        xml.title patron.full_name
        #xml.description(patron.title)
        # rfc822
        xml.pubDate patron.created_at.utc.rfc822
        xml.link patron_url(patron)
        xml.guid patron_url(patron), :isPermaLink => "true"
        #patron.tags.each do |tag|
        #  xml.category tag
        #end
      end
    end
  }
}
