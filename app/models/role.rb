class Role < ApplicationRecord
  include MasterModel
  validates :name, presence: true, format: { with: /\A[A-Za-z][a-z_,]*[a-z]\z/ }
  has_many :user_has_roles, dependent: :destroy
  has_many :users, through: :user_has_roles

  extend FriendlyId
  friendly_id :name

  def localized_name
    display_name.localize
  end

  def self.default
    Role.find_by(name: 'Guest')
  end

  private

  def valid_name?
    true
  end
end

# == Schema Information
#
# Table name: roles
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :string
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  score        :integer          default(0), not null
#  position     :integer
#
