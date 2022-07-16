graph = RDF::Graph.new
@manifestations.each do |manifestation|
  graph << manifestation.rdf_statement
end
graph.dump(:turtle)
