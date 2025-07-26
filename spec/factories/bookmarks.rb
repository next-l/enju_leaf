FactoryBot.define do
  factory :bookmark do
    sequence(:title) {|n| "bookmark_#{n}"}
    sequence(:url) {|n| "http://example.jp/#{n}"}
    user_id {FactoryBot.create(:user).id}
    association :manifestation
  end
end

# == Schema Information
#
# Table name: bookmarks
#
#  id               :bigint           not null, primary key
#  note             :text
#  shared           :boolean
#  title            :text
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  manifestation_id :bigint
#  user_id          :bigint           not null
#
# Indexes
#
#  index_bookmarks_on_manifestation_id  (manifestation_id)
#  index_bookmarks_on_url               (url)
#  index_bookmarks_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
