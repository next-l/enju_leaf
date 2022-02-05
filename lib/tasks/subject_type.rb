def update_subject_type
  concept = SubjectType.where(name: 'Concept').first
  concept&.update_column(:name, 'concept')
  event = SubjectType.where(name: 'Event').first
  event&.update_column(:name, 'event')
  object = SubjectType.where(name: 'Object').first
  object&.update_column(:name, 'object')
  place = SubjectType.where(name: 'Place').first
  place&.update_column(:name, 'place')
end
