class NcidRecord < ApplicationRecord
  belongs_to :manifestation
  validates :body, presence: true, uniqueness: true
  strip_attributes
end

# == Schema Information
#
# Table name: ncid_records
#
#  id               :bigint           not null, primary key
#  manifestation_id :bigint           not null
#  body             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
