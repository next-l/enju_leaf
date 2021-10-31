def update_subject_heading_type
  unknown = SubjectHeadingType.where(name: 'unknown').first
  unless unknown
    SubjectHeadingType.create!(name: 'unknown')
  end
end
