class Area < ActiveRecord::Base
  default_scope :order => 'id DESC'

  validates_presence_of :name, :address

  def self.per_page
    10
  end
end
