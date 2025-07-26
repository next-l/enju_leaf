class UserGroup < ApplicationRecord
  include MasterModel
  include EnjuCirculation::EnjuUserGroup
  has_many :profiles, dependent: :destroy

  validates :valid_period_for_new_user,
    numericality: { greater_than_or_equal_to: 0,
    allow_blank: true }

  paginates_per 10
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
