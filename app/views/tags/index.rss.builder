xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
        'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
        'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('page.listing', :model => t('activerecord.models.tag')) + " (#{@library_group.display_name.localize})"
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => nil))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => "rss"))}"
    xml.tag! "atom:link", :rel => 'alternate', :href => tags_url
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "#{root_url}page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @tags.offset + 1
      xml.tag! "opensearch:itemsPerPage", @tags.per_page
      xml.tag! "opensearch:Query", :role => 'request', :searchTerms => h(params[:query]), :startPage => (h(params[:page]) || 1)
    end
    for tag in @tags
      xml.item do
        xml.title h(tag.name)
        xml.pubDate h(tag.created_at.utc.iso8601)
        xml.link tag_url(tag.name)
        xml.guid tag_url(tag.name), :isPermaLink => "true"
      end
    end
  }
}
