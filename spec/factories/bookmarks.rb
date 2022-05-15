FactoryBot.define do
  factory :bookmark do
    sequence(:title){|n| "bookmark_#{n}"}
    sequence(:url){|n| "http://example.jp/#{n}"}
    user_id{FactoryBot.create(:user).id}
    association :manifestation
  end
end

# == Schema Information
#
# Table name: bookmarks
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  manifestation_id :integer
#  title            :text
#  url              :string
#  note             :text
#  shared           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#
