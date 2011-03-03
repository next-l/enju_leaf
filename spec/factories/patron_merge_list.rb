Factory.define :patron_merge_list do |f|
  f.sequence(:title){|n| "patron_merge_list_#{n}"}
end
