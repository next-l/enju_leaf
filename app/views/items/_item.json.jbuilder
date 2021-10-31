json.id item.id
json.manifestation_id item.manifestation_id
json.item_identifier item.item_identifier
json.call_number item.call_number
json.shelf item.shelf.name
if defined?(EnjuCirculation)
  json.circulation_status item.circulation_status&.name
end
json.binding_item_identifier item.binding_item_identifier
json.binding_call_number item.binding_call_number
json.binded_at item.binded_at
json.acquired_at item.acquired_at
json.include_supplements item.include_supplements
json.url item.url
json.note item.note
json.created_at item.created_at
json.updated_at item.updated_at
