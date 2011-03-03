Factory.define :subject_heading_type_has_subject do |f|
  f.subject_heading_type{Factory(:subject_heading_type)}
  f.subject{Factory(:subject)}
end
