class LossItem < ActiveRecord::Base
  default_scope order('created_at DESC')

  belongs_to :user 
  belongs_to :item

  validates_presence_of :item_id, :user_id, :status

  # consts
  UnPaid=0

  def self.per_page
    10
  end

  searchable do
    text :note
    integer :status
    integer :item_id 
    integer :user_id 
    time :created_at
    time :updated_at
  end
end
