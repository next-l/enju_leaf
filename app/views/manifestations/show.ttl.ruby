graph = RDF::Graph.new
graph << @manifestation.rdf_statement
graph.dump(:turtle)
