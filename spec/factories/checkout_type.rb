Factory.define :checkout_type do |f|
  f.sequence(:name){|n| "checkout_type_#{n}"}
end
