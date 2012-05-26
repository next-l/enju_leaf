class Bookstore < ActiveRecord::Base
  attr_accessible :name, :zip_code, :address, :note, :telephone_number,
    :fax_number, :url
  default_scope :order => "bookstores.position"
  has_many :items

  acts_as_list
  validates_presence_of :name
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}

  def self.per_page
    10
  end

  if defined?(EnjuPurchaseRequest)
    has_many :order_lists
  end
end

# == Schema Information
#
# Table name: bookstores
#
#  id               :integer         not null, primary key
#  name             :text            not null
#  zip_code         :string(255)
#  address          :text
#  note             :text
#  telephone_number :string(255)
#  fax_number       :string(255)
#  url              :string(255)
#  position         :integer
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#

