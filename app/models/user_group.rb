# -*- encoding: utf-8 -*-
class UserGroup < ActiveRecord::Base
  attr_accessible :name, :display_name, :note, :valid_period_for_new_user,
    :expired_at, :number_of_day_to_notify_overdue,
    :number_of_day_to_notify_overdue,
    :number_of_day_to_notify_due_date,
    :number_of_time_to_notify_overdue

  include MasterModel
  default_scope :order => "user_groups.position"
  has_many :users

  validates_numericality_of :valid_period_for_new_user,
    :greater_than_or_equal_to => 0,
    :allow_blank => true

  def self.per_page
    10
  end
end

# == Schema Information
#
# Table name: user_groups
#
#  id                               :integer         not null, primary key
#  name                             :string(255)
#  display_name                     :text
#  note                             :text
#  position                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  deleted_at                       :datetime
#  valid_period_for_new_user        :integer         default(0), not null
#  expired_at                       :datetime
#  number_of_day_to_notify_overdue  :integer         default(1), not null
#  number_of_day_to_notify_due_date :integer         default(7), not null
#  number_of_time_to_notify_overdue :integer         default(3), not null
#

