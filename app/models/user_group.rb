# -*- encoding: utf-8 -*-
class UserGroup < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :users
  #has_many :available_carrier_types
  #has_many :carrier_types, :through => :available_carrier_types, :order => :position
  has_many :user_group_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :user_group_has_checkout_types, :order => :position
  has_many :lending_policies
  has_many :statistics

  validates_numericality_of :valid_period_for_new_user,
    :number_of_day_to_notify_due_date,
    :number_of_day_to_notify_overdue,
    :number_of_time_to_notify_overdue,
    :greater_than_or_equal_to => 0

  attr_accessible :name, :display_name, :valid_period_for_new_user, :number_of_day_to_notify_due_date,
                 :number_of_day_to_notify_overdue, :number_of_time_to_notify_overdue, :note

  paginates_per 10
end

# == Schema Information
#
# Table name: user_groups
#
#  id                               :integer         not null, primary key
#  name                             :string(255)
#  string                           :string(255)
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

