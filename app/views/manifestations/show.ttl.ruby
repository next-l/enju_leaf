graph = RDF::Graph.new
graph << rdf_statement(@manifestation)
graph.dump(:turtle)
