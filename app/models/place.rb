class Place < ApplicationRecord
  has_many :events, dependent: :destroy
  validates :term, presence: true
end

# == Schema Information
#
# Table name: places
#
#  id         :bigint           not null, primary key
#  term       :string
#  city       :text
#  country_id :bigint
#  latitude   :float
#  longitude  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
