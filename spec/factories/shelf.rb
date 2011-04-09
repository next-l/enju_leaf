Factory.define :shelf do |f|
  f.sequence(:name){|n| "shelf_#{n}"}
  f.sequence(:library){Factory(:library)}
end
