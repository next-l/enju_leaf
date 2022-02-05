xml.instruct! :xml, :version => "1.0"
xml.OpenSearchDescription(
  'xmlns' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:moz' => 'http://www.mozilla.org/2006/browser/search/'){
  xml.ShortName @library_group.display_name.localize
  xml.Description @library_group.display_name.localize
  xml.Tags 'Library Catalog'
  xml.Contact @library_group.user.email
  xml.Url type: 'text/html', template: "#{manifestations_url}?query={searchTerms}"
  xml.Url type: 'application/rss+xml', template: "#{manifestations_url(format: :rss)}?query={searchTerms}"
  xml.Query role: 'example', searchTerms: 'enju'
  xml.Language @locale.to_s
  xml.OutputEncoding 'UTF-8'
  xml.InputEncoding 'UTF-8'
  xml.Image "#{root_url}favicon.ico", width: 16, height: 16, type: 'image/x-icon'
  xml.tag! 'moz:SearchForm', root_url
}
