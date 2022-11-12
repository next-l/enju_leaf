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
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  manifestation_id :bigint
#  title            :text
#  url              :string
#  note             :text
#  shared           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
