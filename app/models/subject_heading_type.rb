class SubjectHeadingType < ApplicationRecord
  include MasterModel
  has_many :subjects, dependent: :destroy
  validates :name, format: {with: /\A[0-9a-z][0-9a-z_\-]*[0-9a-z]\Z/}
end

# == Schema Information
#
# Table name: subject_heading_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
