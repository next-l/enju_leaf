Factory.define :frequency do |f|
  f.sequence(:name){|n| "frequency_#{n}"}
end
