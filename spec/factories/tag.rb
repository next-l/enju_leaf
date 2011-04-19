Factory.define :tag do |f|
  f.sequence(:name){|n| "tag_#{n}"}
end
