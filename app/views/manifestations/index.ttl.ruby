graph = RDF::Graph.new
@manifestations.each do |manifestation|
  graph << RDF::Statement.new(
    RDF::URI.new(manifestation_url(manifestation)),
    nextl.original_title,
    RDF::Literal.new(manifestation.original_title)
  )
end
graph.dump(:turtle)
