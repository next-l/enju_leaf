class Bookstore < ActiveRecord::Base
  default_scope :order => "position"
  has_many :items
  has_many :order_lists

  acts_as_list
  validates_presence_of :name
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  validates :email, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}, :allow_blank => true

  paginates_per 10

  def self.import_bookstore(bookstore_name)
    bookstore = Bookstore.where(:name => bookstore_name).first
    unless bookstore
      bookstore = Bookstore.new(
        :name => bookstore_name
      )
      bookstore.save
    end
    bookstore
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

