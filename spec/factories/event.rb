Factory.define :event do |f|
  f.sequence(:name){|n| "event_#{n}"}
  f.library{Factory(:library)}
  f.event_category{Factory(:event_category)}
end
