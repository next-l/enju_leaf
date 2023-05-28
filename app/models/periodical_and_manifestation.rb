class PeriodicalAndManifestation < ApplicationRecord
  belongs_to :periodical
  belongs_to :manifestation
end

# == Schema Information
#
# Table name: periodical_and_manifestations
#
#  id               :bigint           not null, primary key
#  periodical_id    :bigint           not null
#  manifestation_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
