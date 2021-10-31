class UseRestriction < ApplicationRecord
  include MasterModel
  validates :name, presence: true, format: { with: /\A[0-9A-Za-z][0-9A-Za-z_\-\s,]*[0-9a-z]\Z/ }

  scope :available, -> {where(name: ['Not For Loan', 'Limited Circulation, Normal Loan Period'])}
  has_many :item_has_use_restrictions
  has_many :items, through: :item_has_use_restrictions

  private

  def valid_name?
    true
  end
end

# == Schema Information
#
# Table name: use_restrictions
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
