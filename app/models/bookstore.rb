class Bookstore < ActiveRecord::Base
  has_many :items
  has_many :order_lists

  acts_as_list
  validates_presence_of :name
  validates_length_of :url, :maximum => 255, :allow_blank => true

  def self.per_page
    10
  end
end
