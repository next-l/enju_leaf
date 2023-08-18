class IssnRecordAndManifestation < ApplicationRecord
  belongs_to :issn_record
  belongs_to :manifestation
end

# == Schema Information
#
# Table name: issn_record_and_manifestations
#
#  id               :bigint           not null, primary key
#  issn_record_id   :bigint           not null
#  manifestation_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
