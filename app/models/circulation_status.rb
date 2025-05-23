class CirculationStatus < ApplicationRecord
  include MasterModel
  validates :name, presence: true, format: { with: /\A[0-9A-Za-z][0-9A-Za-z_\-\s,]*[0-9a-z]\Z/ }

  default_scope { order("circulation_statuses.position") }
  scope :available_for_checkout, -> { where(name: "Available On Shelf") }
  has_many :items, dependent: :restrict_with_exception

  private

  def valid_name?
    true
  end
end

# == Schema Information
#
# Table name: circulation_statuses
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
#  index_circulation_statuses_on_lower_name  (lower((name)::text)) UNIQUE
#
