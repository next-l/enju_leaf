xml.instruct! :xml, version: "1.0"
xml.rss("version" => "2.0",
  "xmlns:opensearch" => "http://a9.com/-/spec/opensearch/1.1/",
  "xmlns:atom" => "http://www.w3.org/2005/Atom") {
  xml.channel {
    if @user
      xml.title t("message.user_message", login_name: @user.username)
      xml.link messages_url(@user, format: :rss)
    else
      xml.title t("message.library_group_message", library_group_name: @library_group.display_name)
      xml.link messages_url(format: :rss)
    end
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale.to_s
    xml.ttl "60"
    xml.tag! "atom:link", rel: "self", href: messages_url(format: :rss)
    xml.tag! "atom:link", rel: "alternate", href: messages_url
    # xml.tag! "atom:link", rel: 'search', type: 'application/opensearchdescription+xml', href: "http://#{request.host_with_port}/page/opensearch"
    if params[:query].present?
      xml.tag! "opensearch:totalResults", @messages.total_entries
      xml.tag! "opensearch:startIndex", @messages.offset + 1
      xml.tag! "opensearch:itemsPerPage", @messages.per_page
      # xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    @messages.each do |message|
      xml.item do
        xml.title message.subject
        # xml.description(message.title)
        # rfc822
        xml.pubDate message.created_at.utc.rfc822
        xml.link message_url(message)
        xml.guid message_url(message), isPermaLink: "true"
      end
    end
  }
}
