class LendingPolicy < ActiveRecord::Base
  default_scope :order => 'position'
  belongs_to :item
  belongs_to :user_group

  validates_presence_of :item, :user_group
  validates_uniqueness_of :user_group_id, :scope => :item_id

  acts_as_list :scope => :item_id

  paginates_per 10
end
