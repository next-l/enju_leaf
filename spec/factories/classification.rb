Factory.define :classification do |f|
  f.sequence(:category){|n| "classification_#{n}"}
  f.classification_type{Factory(:classification_type)}
end
