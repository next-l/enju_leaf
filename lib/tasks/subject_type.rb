def update_subject_type
  concept = SubjectType.where(name: 'Concept').first
  concept.update_column(:name, 'concept') if concept
  event = SubjectType.where(name: 'Event').first
  event.update_column(:name, 'event') if event
  object = SubjectType.where(name: 'Object').first
  object.update_column(:name, 'object') if object
  place = SubjectType.where(name: 'Place').first
  place.update_column(:name, 'place') if place
end
