FactoryGirl.define do
  factory :search_engine do |f|
    f.sequence(:name){|n| "search_engine_#{n}"}
    f.sequence(:url){|n| "http://search-engine-#{n}.example.jp"}
    f.sequence(:base_url){|n| "http://search-engine-#{n}.example.jp"}
    f.query_param 'q'
    f.http_method 'get'
  end
end
