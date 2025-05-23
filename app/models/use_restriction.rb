class UseRestriction < ApplicationRecord
  include MasterModel
  validates :name, presence: true, format: { with: /\A[0-9A-Za-z][0-9A-Za-z_\-\s,]*[0-9a-z]\Z/ }

  scope :available, -> { where(name: [ "Not For Loan", "Limited Circulation, Normal Loan Period" ]) }
  has_many :item_has_use_restrictions, dependent: :destroy
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
#  id           :bigint           not null, primary key
#  display_name :text
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_use_restrictions_on_lower_name  (lower((name)::text)) UNIQUE
#
