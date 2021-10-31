FactoryBot.define do
  factory :user_group_has_checkout_type do |f|
    f.user_group_id{FactoryBot.create(:user_group).id}
    f.checkout_type_id{FactoryBot.create(:checkout_type).id}
  end
end

# == Schema Information
#
# Table name: user_group_has_checkout_types
#
#  id                              :integer          not null, primary key
#  user_group_id                   :integer          not null
#  checkout_type_id                :integer          not null
#  checkout_limit                  :integer          default(0), not null
#  checkout_period                 :integer          default(0), not null
#  checkout_renewal_limit          :integer          default(0), not null
#  reservation_limit               :integer          default(0), not null
#  reservation_expired_period      :integer          default(7), not null
#  set_due_date_before_closing_day :boolean          default(FALSE), not null
#  fixed_due_date                  :datetime
#  note                            :text
#  position                        :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  current_checkout_count          :integer
#
