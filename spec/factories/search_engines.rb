FactoryBot.define do
  factory :search_engine do |f|
    f.sequence(:name){|n| "search_engine_#{n}"}
    f.sequence(:url){|n| "http://search-engine-#{n}.example.jp"}
    f.sequence(:base_url){|n| "http://search-engine-#{n}.example.jp"}
    f.query_param { 'q' }
    f.http_method { 'get' }
  end
end

# == Schema Information
#
# Table name: search_engines
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  display_name     :text
#  url              :string           not null
#  base_url         :text             not null
#  http_method      :text             not null
#  query_param      :text             not null
#  additional_param :text
#  note             :text
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
