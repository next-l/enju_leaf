xml.instruct! :xml, :version=>"1.0"
xml.rdf(:RDF,
        'xmlns'  => "http://purl.org/rss/1.0/",
        'xmlns:rdf'  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:foaf' => "http://xmlns.com/foaf/0.1/",
        'xmlns:prism' => "http://prismstandard.org/namespaces/basic/2.0/",
        'xmlns:rdfs' =>"http://www.w3.org/2000/01/rdf-schema#") do
  xml << render('manifestations/show', :manifestation => @manifestation)
end
