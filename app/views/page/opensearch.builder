xml.instruct! :xml, :version=>"1.0" 
xml.OpenSearchDescription(
  'xmlns' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:moz' => 'http://www.mozilla.org/2006/browser/search/'){
  xml.ShortName h(@library_group.display_name.localize)
  xml.Description h(@library_group.display_name.localize)
  xml.Tags 'Library Catalog'
  xml.Contact h(@library_group.email)
  xml.Url :type => 'text/html', :template => "#{manifestations_url}?query={searchTerms}&pages={startPage?}"
  xml.Url :type => 'application/rss+xml', :template => "#{manifestations_url(:format => :rss)}?query={searchTerms}&pages={startPage?}"
  xml.Query :role => 'example', :searchTerms => 'enju'
  xml.Language @locale
  xml.OutputEncoding 'UTF-8'
  xml.InputEncoding 'UTF-8'
  xml.tag! 'moz:SearchForm', root_url
}
