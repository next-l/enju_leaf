xml.instruct! :xml, version: "1.0"
xml.rdf(:RDF,
        "xmlns" => "http://purl.org/rss/1.0/",
        "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dcndl" => "http://ndl.go.jp/dcndl/terms/",
        "xmlns:foaf" => "http://xmlns.com/foaf/0.1/",
        "xmlns:prism" => "http://prismstandard.org/namespaces/basic/2.0/",
        "xmlns:rdfs" => "http://www.w3.org/2000/01/rdf-schema#"){
  xml.channel("rdf:about" => manifestations_url(params: request.params.merge(format: "rdf", only_path: true))){
    xml.title t("manifestation.query_search_result", query: @query, library_group_name: @library_group.display_name.localize)
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(request.params.merge(format: nil, only_path: true))}"
    xml.description "Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale.to_s
    xml.ttl "60"
    if @manifestations
      xml.items do
        xml.tag! "rdf:Seq" do
          @manifestations.each do |manifestation|
            xml.tag! "rdf:li", "rdf:resource" => manifestation_url(manifestation)
          end
        end
      end
    end
  }
  @manifestations.each do |manifestation|
    xml.item("rdf:about" => manifestation_url(manifestation)) do
      xml << render("manifestations/show", manifestation: manifestation)
    end
  end
}
