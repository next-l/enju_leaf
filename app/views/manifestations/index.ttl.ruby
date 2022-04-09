graph = RDF::Graph.new
@manifestations.each do |manifestation|
  graph << rdf_statement(manifestation)
end
graph.dump(:turtle)
