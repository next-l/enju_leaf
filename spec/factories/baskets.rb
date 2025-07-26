FactoryBot.define do
  factory :basket do |f|
    f.user_id {FactoryBot.create(:user).id}
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :bigint           not null, primary key
#  lock_version :integer          default(0), not null
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#
# Indexes
#
#  index_baskets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
