class LendingPolicy < ActiveRecord::Base
  attr_accessible :item_id, :user_group_id, :fixed_due_date, :loan_period, :renewal
  default_scope :order => 'position'
  belongs_to :item
  belongs_to :user_group

  validates_presence_of :item, :user_group
  validates_uniqueness_of :user_group_id, :scope => :item_id

  paginates_per 10

  acts_as_list :scope => :item_id
end

# == Schema Information
#
# Table name: lending_policies
#
#  id             :integer         not null, primary key
#  item_id        :integer         not null
#  user_group_id  :integer         not null
#  loan_period    :integer         default(0), not null
#  fixed_due_date :datetime
#  renewal        :integer         default(0), not null
#  fine           :decimal(, )     default(0.0), not null
#  note           :text
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

