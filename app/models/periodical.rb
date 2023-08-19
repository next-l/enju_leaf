class Periodical < ApplicationRecord
  belongs_to :manifestation
  belongs_to :frequency
  has_many :periodical_and_manifestations, dependent: :destroy
  has_many :manifestations, through: :periodical_and_manifestations

  validates :original_title, presence: true
end

# == Schema Information
#
# Table name: periodicals
#
#  id               :bigint           not null, primary key
#  original_title   :text             not null
#  manifestation_id :bigint           not null
#  frequency_id     :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
