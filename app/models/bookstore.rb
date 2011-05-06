class Bookstore < ActiveRecord::Base
  default_scope :order => "position"
  has_many :items
  has_many :order_lists

  acts_as_list
  validates_presence_of :name
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}

  def self.per_page
    10
  end
end
