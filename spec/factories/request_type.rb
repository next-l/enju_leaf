Factory.define :request_type do |f|
  f.sequence(:name){|n| "request_type_#{n}"}
end
