class ClassificationType < ApplicationRecord
  include MasterModel
  has_many :classifications
  validates :name, format: { with: /\A[0-9a-z][0-9a-z_\-]*[0-9a-z]\Z/ }
end

# == Schema Information
#
# Table name: classification_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
