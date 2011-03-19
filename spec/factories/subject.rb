Factory.define :subject do |f|
  f.sequence(:term){|n| "subject_#{n}"}
  f.subject_type{Factory(:subject_type)}
end
