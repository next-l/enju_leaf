class LossItem < ActiveRecord::Base
  default_scope order('created_at DESC')

  belongs_to :user 
  belongs_to :item

  validates_presence_of :item_id, :user_id, :status

  # consts
  UnPaid=0
end
