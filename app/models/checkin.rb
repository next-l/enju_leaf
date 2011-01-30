class Checkin < ActiveRecord::Base
  default_scope :order => 'id DESC'
  has_one :checkout
  belongs_to :item
  belongs_to :librarian, :class_name => 'User'
  belongs_to :basket

  validates_presence_of :item, :basket, :on => :update
  validates_associated :item, :librarian, :basket, :on => :update

  attr_accessor :item_identifier

end
