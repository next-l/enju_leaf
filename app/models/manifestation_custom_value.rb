class ManifestationCustomValue < ApplicationRecord
  belongs_to :manifestation_custom_property
  belongs_to :manifestation
  validates :manifestation_custom_property, uniqueness: {scope: :manifestation_id}
end

# == Schema Information
#
# Table name: manifestation_custom_values
#
#  id                               :bigint           not null, primary key
#  manifestation_custom_property_id :bigint           not null
#  manifestation_id                 :bigint           not null
#  value                            :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
