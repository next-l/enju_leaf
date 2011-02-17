Factory.define :license do |f|
  f.sequence(:name){|n| "license_#{n}"}
end
