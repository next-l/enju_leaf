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
#  user_id                      :bigint           not null
#  manifestation_id             :bigint           not null
#  item_id                      :bigint
#  request_status_type_id       :integer          not null
#  checked_out_at               :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  canceled_at                  :datetime
#  expired_at                   :datetime
#  expiration_notice_to_patron  :boolean          default(FALSE)
#  expiration_notice_to_library :boolean          default(FALSE)
#  pickup_location_id           :integer
#  retained_at                  :datetime
#  postponed_at                 :datetime
#  lock_version                 :integer          default(0), not null
#
