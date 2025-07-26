FactoryBot.define do
  factory :reserve do
    before(:create) do |reserve|
      profile = FactoryBot.create(:profile)
      user = User.new(FactoryBot.attributes_for(:user))
      user.profile = profile
      reserve.user = user
    end
    after(:build) do |reserve|
      item = FactoryBot.create(:item, use_restriction: UseRestriction.find_by(name: 'Available On Shelf'))
      reserve.manifestation = item.manifestation
      reserve.item = item
    end
  end
end

# == Schema Information
#
# Table name: reserves
#
#  id                           :bigint           not null, primary key
#  canceled_at                  :datetime
#  checked_out_at               :datetime
#  expiration_notice_to_library :boolean          default(FALSE)
#  expiration_notice_to_patron  :boolean          default(FALSE)
#  expired_at                   :datetime
#  lock_version                 :integer          default(0), not null
#  postponed_at                 :datetime
#  retained_at                  :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  item_id                      :bigint
#  manifestation_id             :bigint           not null
#  pickup_location_id           :bigint
#  request_status_type_id       :bigint           not null
#  user_id                      :bigint           not null
#
# Indexes
#
#  index_reserves_on_item_id             (item_id)
#  index_reserves_on_manifestation_id    (manifestation_id)
#  index_reserves_on_pickup_location_id  (pickup_location_id)
#  index_reserves_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_id => manifestations.id)
#  fk_rails_...  (user_id => users.id)
#
