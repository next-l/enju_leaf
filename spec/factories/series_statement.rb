Factory.define :series_statement do |f|
  f.sequence(:original_title){|n| "series_statement_#{n}"}
end
