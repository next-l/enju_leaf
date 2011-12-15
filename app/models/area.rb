class Area < ActiveRecord::Base
  default_scope :order => 'id DESC'

  validates_presence_of :name, :address

  searchable do
    text :name, :address
    time :created_at
    time :updated_at
  end

  def self.per_page
    10
  end
end
