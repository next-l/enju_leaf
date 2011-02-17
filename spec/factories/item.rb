Factory.define :item do |f|
  f.sequence(:item_identifier){|n| "item_#{n}"}
end
