xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title t('answer.user_answer', :login_name => @user.username)
    xml.link "#{request.protocol}#{request.host_with_port}" + user_answers_path(@user.username)
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => "rss"))}"
    xml.tag! "atom:link", :rel => 'alternate', :href => "#{request.protocol}#{request.host_with_port}"
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @answers.offset + 1
      xml.tag! "opensearch:itemsPerPage", @answers.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    for answer in @answers
      xml.item do
        xml.title answer.body
        #xml.description(answer.title)
        # rfc822
        xml.pubDate answer.created_at.utc.iso8601
        xml.link "#{request.protocol}#{request.host_with_port}" + user_answer_path(@user.username, answer)
        xml.guid "#{request.protocol}#{request.host_with_port}" + user_answer_path(answer.user.username, answer), :isPermaLink => "true"
      end
    end
  }
}
