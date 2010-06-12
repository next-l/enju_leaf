xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
        'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('manifestation.query_search_result', :query => @query, :library_group_name => @library_group.display_name.localize)
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => nil))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => "rss"))}"
    xml.tag! "atom:link", :rel => 'alternate', :href => resources_url
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "#{request.protocol}#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @resources.total_entries
      xml.tag! "opensearch:startIndex", @resources.offset + 1
      xml.tag! "opensearch:itemsPerPage", @resources.per_page
      xml.tag! "opensearch:Query", :role => 'request', :searchTerms => h(params[:query]), :startPage => (h(params[:page]) || 1)
    end
    if @resources
      @resources.each do |manifestation|
          xml.item do
            xml.title h(manifestation.original_title)
            #xml.description(manifestation.original_title)
            # rfc822
            manifestation.creators.each do |creator|
              xml.tag! "dc:creator", creator.full_name
            end
            xml.pubDate h(manifestation.created_at.utc.iso8601)
            xml.link resource_url(manifestation)
            xml.guid resource_url(manifestation), :isPermaLink => "true"
            manifestation.tags.each do |tag|
              xml.category h(tag)
            end
            xml.tag! "dc:Identifier", manifestation.isbn
          end
        end
    end
  }
}
