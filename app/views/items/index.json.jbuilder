json.results do
  json.array!(@items) do |item|
    json.partial!(item)
  end
end
