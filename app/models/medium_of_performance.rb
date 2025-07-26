class MediumOfPerformance < ApplicationRecord
  include MasterModel
  has_many :works, class_name: "Manifestation"
end

# == Schema Information
#
# Table name: medium_of_performances
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
#  index_medium_of_performances_on_lower_name  (lower((name)::text)) UNIQUE
#
