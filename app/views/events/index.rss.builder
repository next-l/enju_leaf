xml.instruct! :xml, version: "1.0"
xml.rss("version" => "2.0",
  "xmlns:opensearch" => "http://a9.com/-/spec/opensearch/1.1/",
  "xmlns:atom" => "http://www.w3.org/2005/Atom") {
  xml.channel {
    xml.title t("event.library_group_event", library_group_name: @library_group.display_name.localize)
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(params.permit.merge(format: nil, only_path: true))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale.to_s
    xml.ttl "60"
    xml.tag! "atom:link", rel: "self", href: "#{request.protocol}#{request.host_with_port}#{url_for(params.permit.merge(format: :rss, only_path: true))}"
    xml.tag! "atom:link", rel: "alternate", href: events_url
    # xml.tag! "atom:link", rel: 'search', :type => 'application/opensearchdescription+xml', href: "http://#{request.host_with_port}/page/opensearch"
    if params[:query].present?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @events.offset + 1
      xml.tag! "opensearch:itemsPerPage", @events.per_page
      # xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    @events.each do |event|
      xml.item do
        xml.title event.display_name.localize
        xml.description event.note
        # rfc822
        xml.pubDate event.created_at.rfc2822
        xml.link event_url(event)
        xml.guid event_url(event), isPermaLink: "true"
        # event.tags.each do |tag|
        #  xml.category tag.name
        # end
      end
    end
  }
}
