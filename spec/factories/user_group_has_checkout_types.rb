FactoryBot.define do
  factory :user_group_has_checkout_type do |f|
    f.user_group_id {FactoryBot.create(:user_group).id}
    f.checkout_type_id {FactoryBot.create(:checkout_type).id}
  end
end

# == Schema Information
#
# Table name: user_group_has_checkout_types
#
#  id                              :bigint           not null, primary key
#  checkout_limit                  :integer          default(0), not null
#  checkout_period                 :integer          default(0), not null
#  checkout_renewal_limit          :integer          default(0), not null
#  current_checkout_count          :integer
#  fixed_due_date                  :datetime
#  note                            :text
#  position                        :integer
#  reservation_expired_period      :integer          default(7), not null
#  reservation_limit               :integer          default(0), not null
#  set_due_date_before_closing_day :boolean          default(FALSE), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  checkout_type_id                :bigint           not null
#  user_group_id                   :bigint           not null
#
# Indexes
#
#  index_user_group_has_checkout_types_on_checkout_type_id  (checkout_type_id)
#  index_user_group_has_checkout_types_on_user_group_id     (user_group_id,checkout_type_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (checkout_type_id => checkout_types.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#
