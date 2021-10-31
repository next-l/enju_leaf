json.total_count @count[:query_result]
json.results do
  json.array!(@manifestations) do |manifestation|
    json.partial!(manifestation)
  end
end
