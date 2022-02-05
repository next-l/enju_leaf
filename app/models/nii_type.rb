class NiiType < ApplicationRecord
  include MasterModel
  has_many :manifestations
end

# == Schema Information
#
# Table name: nii_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
