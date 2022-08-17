graph = RDF::Graph.new
nextl = RDF::Vocabulary.new('https://next-l.jp/vocab/')
@manifestations.each do |manifestation|
  graph << RDF::Statement.new(
    RDF::URI.new(manifestation_url(manifestation)),
    nextl.original_title,
    RDF::Literal.new(manifestation.original_title)
  )
end
graph.dump(:turtle)
