class Bookstore < ActiveRecord::Base
  default_scope :order => "position"
  has_many :items
  has_many :order_lists
  
  acts_as_list
  #acts_as_soft_deletable
  validates_presence_of :name
  validates_length_of :url, :maximum => 255, :allow_blank => true

  def self.per_page
    10
  end
end
