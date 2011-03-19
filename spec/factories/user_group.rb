Factory.define :user_group do |f|
  f.sequence(:name){|n| "user_group_#{n}"}
end
