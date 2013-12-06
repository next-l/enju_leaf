class LossItem < ActiveRecord::Base
  default_scope order('created_at DESC')

  belongs_to :user 
  belongs_to :item

  validates_presence_of :user_id, :item_id, :status
  validate :check_user_number

  attr_accessor :user_number
  attr_accessible :item_id, :user_id, :note

  # consts
  UnPaid=0

  paginates_per 10

  def check_user_number
    unless self.user_number.blank?
      user = User.where(:user_number => self.user_number).first
      errors[:base] << I18n.t('user.not_found') unless user
    end
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
