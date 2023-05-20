json.id manifestation.id
json.original_title manifestation.original_title
json.title_alternative manifestation.title_alternative
json.title_transcription manifestation.title_transcription
json.title_alternative_transcription manifestation.title_alternative_transcription
json.pub_date manifestation.pub_date
json.statement_of_responsibility manifestation.statement_of_responsibility
json.creators do
  json.array!(manifestation.creators) do |creator|
    json.full_name creator.full_name
  end
end
json.contributors do
  json.array!(manifestation.contributors) do |contributor|
    json.full_name contributor.full_name
  end
end
json.publishers do
  json.array!(manifestation.publishers) do |publisher|
    json.full_name publisher.full_name
  end
end
json.publication_place manifestation.publication_place
json.extent manifestation.extent
json.dimensions manifestation.dimensions
json.identifiers do
  json.array!(manifestation.identifiers) do |identifier|
    json.identifier_type identifier.identifier_type.name
    json.body identifier.body
  end
end
json.subjects do
  json.array!(manifestation.subjects) do |subject|
    json.subject_heading_type subject.subject_heading_type.name
    json.term subject.term
  end
end
json.classfifications do
  json.array!(manifestation.classifications) do |classification|
    json.classification_type classification.classification_type.name
    json.term classification.category
  end
end
json.access_address manifestation.access_address
json.items do
  json.array!(policy_scope(manifestation.items).available.on_shelf) do |item|
    json.item_identifier item.item_identifier
    json.shelf item.shelf.display_name
    json.circulation_status item.circulation_status.display_name if defined?(EnjuCirculationStatus)
  end
end
json.created_at manifestation.created_at
json.updated_at manifestation.updated_at
