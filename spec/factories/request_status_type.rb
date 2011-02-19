Factory.define :request_status_type do |f|
  f.sequence(:name){|n| "request_status_type_#{n}"}
end
