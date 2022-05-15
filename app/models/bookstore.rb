class Bookstore < ApplicationRecord
  default_scope { order('bookstores.position') }
  has_many :items, dependent: :restrict_with_exception

  acts_as_list
  validates :name, presence: true
  validates :url, url: true, allow_blank: true, length: { maximum: 255 }

  paginates_per 10

  if defined?(EnjuPurchaseRequest)
    has_many :order_lists, dependent: :restrict_with_exception
  end
end

# == Schema Information
#
# Table name: bookstores
#
#  id               :integer          not null, primary key
#  name             :text             not null
#  zip_code         :string
#  address          :text
#  note             :text
#  telephone_number :string
#  fax_number       :string
#  url              :string
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#
