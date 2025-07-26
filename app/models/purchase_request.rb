class PurchaseRequest < ApplicationRecord
  scope :not_ordered, -> { includes(:order_list).where("order_lists.ordered_at IS NULL") }
  scope :ordered, -> { includes(:order_list).where("order_lists.ordered_at IS NOT NULL") }

  belongs_to :user, validate: true
  has_one :order, dependent: :destroy
  has_one :order_list, through: :order

  validates_associated :user
  validates_presence_of :user, :title
  validate :check_price
  validates :url, url: true, allow_blank: true, length: { maximum: 255 }
  after_destroy :index!
  after_save :index!
  before_save :set_date_of_publication

  strip_attributes only: [ :url, :pub_date ]

  searchable do
    text :title, :author, :publisher, :url
    string :isbn
    string :url
    integer :price
    integer :user_id
    integer :order_list_id do
      order_list.id if order_list
    end
    time :pub_date do
      date_of_publication
    end
    time :created_at
    time :accepted_at
    time :denied_at
    boolean :ordered do
      if order_list.try(:current_state) == "ordered"
        true
      else
        false
      end
    end
  end

  paginates_per 10

  def check_price
    errors.add(:price) unless price.nil? || price.positive?
  end

  def set_date_of_publication
    return if pub_date.blank?
    begin
      date = Time.zone.parse("#{pub_date}")
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{pub_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{pub_date}-01-01")
        rescue ArgumentError
          nil
        end
      end
    end
    self.date_of_publication = date
  end
end

# ## Schema Information
#
# Table name: `purchase_requests`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`accepted_at`**          | `datetime`         |
# **`author`**               | `text`             |
# **`date_of_publication`**  | `datetime`         |
# **`denied_at`**            | `datetime`         |
# **`isbn`**                 | `string`           |
# **`note`**                 | `text`             |
# **`price`**                | `integer`          |
# **`pub_date`**             | `string`           |
# **`publisher`**            | `text`             |
# **`state`**                | `string`           |
# **`title`**                | `text`             | `not null`
# **`url`**                  | `string`           |
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`user_id`**              | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_purchase_requests_on_state`:
#     * **`state`**
# * `index_purchase_requests_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
