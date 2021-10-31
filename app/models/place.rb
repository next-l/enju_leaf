class Place < ApplicationRecord
  has_many :events
  validates :term, presence: true
end

# == Schema Information
#
# Table name: places
#
#  id         :integer          not null, primary key
#  term       :string
#  city       :text
#  country_id :integer
#  latitude   :float
#  longitude  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
