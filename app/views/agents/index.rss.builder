xml.instruct! :xml, version: "1.0"
xml.rss('version' => "2.0",
        'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
        'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('agent.library_group_agent', library_group_name: @library_group.display_name.localize)
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(request.params.merge(format: nil, only_path: true))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale.to_s
    xml.ttl "60"
    xml.tag! "atom:link", rel: 'self', href: "#{request.protocol}#{request.host_with_port}#{url_for(request.params.merge(format: :rss, only_path: true))}"
    xml.tag! "atom:link", rel: 'alternate', href: agents_url
    xml.tag! "atom:link", rel: 'search', type: 'application/opensearchdescription+xml', href: page_opensearch_url
    if params[:query].present?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @agents.offset + 1
      xml.tag! "opensearch:itemsPerPage", @agents.per_page
      xml.tag! "opensearch:Query", role: 'request', searchTerms: h(params[:query]), startPage: (h(params[:page]) || 1)
    end
    @agents.each do |agent|
      xml.item do
        xml.title agent.full_name
        #xml.description(agent.title)
        # rfc822
        xml.pubDate agent.created_at.utc.rfc822
        xml.link agent_url(agent)
        xml.guid agent_url(agent), isPermaLink: "true"
        #agent.tags.each do |tag|
        #  xml.category tag
        #end
      end
    end
  }
}
