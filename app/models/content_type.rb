class ContentType < ApplicationRecord
  include MasterModel
  has_many :manifestations, dependent: :restrict_with_exception
end

# == Schema Information
#
# Table name: content_types
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
#  index_content_types_on_lower_name  (lower((name)::text)) UNIQUE
#
