Factory.define :subject_type do |f|
  f.sequence(:name){|n| "subject_type_#{n}"}
end
