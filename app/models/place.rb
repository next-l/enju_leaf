class Place < ApplicationRecord
  has_many :events, dependent: :destroy
  validates :term, presence: true
end
