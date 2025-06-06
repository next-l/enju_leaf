class RequestStatusType < ApplicationRecord
  include MasterModel
  validates :name, presence: true, format: { with: /\A[0-9A-Za-z][0-9A-Za-z_\-\s,]*[0-9a-z]\Z/ }
  has_many :reserves, dependent: :restrict_with_exception

  private

  def valid_name?
    true
  end
end

# == Schema Information
#
# Table name: request_status_types
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
#  index_request_status_types_on_lower_name  (lower((name)::text)) UNIQUE
#
