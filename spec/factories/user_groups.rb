FactoryBot.define do
  factory :user_group do |f|
    f.sequence(:name) {|n| "user_group_#{n}"}
  end
end

# == Schema Information
#
# Table name: user_groups
#
#  id                               :bigint           not null, primary key
#  display_name                     :text
#  expired_at                       :datetime
#  name                             :string           not null
#  note                             :text
#  number_of_day_to_notify_due_date :integer          default(0), not null
#  number_of_day_to_notify_overdue  :integer          default(0), not null
#  number_of_time_to_notify_overdue :integer          default(0), not null
#  position                         :integer
#  valid_period_for_new_user        :integer          default(0), not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
# Indexes
#
#  index_user_groups_on_lower_name  (lower((name)::text)) UNIQUE
#
