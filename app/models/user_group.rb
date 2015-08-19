# -*- encoding: utf-8 -*-
class UserGroup < ActiveRecord::Base
  include MasterModel
  has_many :profiles

  validates_numericality_of :valid_period_for_new_user,
    greater_than_or_equal_to: 0,
    allow_blank: true

  paginates_per 10

  enju_circulation_user_group_model if defined?(EnjuCirculation)
end

# == Schema Information
#
# Table name: user_groups
#
#  id                               :integer          not null, primary key
#  name                             :string
#  display_name                     :text
#  note                             :text
#  position                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  deleted_at                       :datetime
#  valid_period_for_new_user        :integer          default(0), not null
#  expired_at                       :datetime
#  number_of_day_to_notify_overdue  :integer          default(1), not null
#  number_of_day_to_notify_due_date :integer          default(7), not null
#  number_of_time_to_notify_overdue :integer          default(3), not null
#
