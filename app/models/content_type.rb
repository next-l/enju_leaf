class ContentType < ApplicationRecord
  include MasterModel
  has_many :manifestations, dependent: :restrict_with_exception
end

# == Schema Information
#
# Table name: content_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
