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

  paginates_per 10

  enju_circulation_user_group_model if defined?(EnjuCirculation)
end
