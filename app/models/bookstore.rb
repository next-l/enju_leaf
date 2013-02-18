class Bookstore < ActiveRecord::Base
  attr_accessible :name, :name_transcription, :email, :zip_code, :address,
                  :telephone_number, :fax_number, :url, :note, :position
  default_scope :order => "position"
  has_many :items
  has_many :order_lists

  acts_as_list
  validates_presence_of :name
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  validates :email, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}, :allow_blank => true

  paginates_per 10

  searchable do
    text :name, :address, :note, :name_transcription
    string :zip_code
    string :telephone_number
    string :fax_number
    string :url
    string :email
    time :deleted_at
    time :created_at
    time :updated_at
  end

  def self.import_bookstore(bookstore_name)
    bookstore = Bookstore.where(:name => bookstore_name).first rescue nil
    unless bookstore
      unless bookstore_name == '' or bookstore_name.nil?
        bookstore = Bookstore.new(
          :name => bookstore_name
        )
        bookstore.save
      end
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

