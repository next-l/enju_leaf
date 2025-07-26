class IdentifierType < ApplicationRecord
  include MasterModel
  has_many :identifiers, dependent: :destroy
  validates :name, format: { with: /\A[0-9a-z][0-9a-z_\-]*[0-9a-z]\Z/ }
end

# == Schema Information
#
# Table name: identifier_types
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
#  index_identifier_types_on_lower_name  (lower((name)::text)) UNIQUE
#
