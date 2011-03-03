Factory.define :bookstore do |f|
  f.sequence(:name){|n| "bookstore_#{n}"}
end
