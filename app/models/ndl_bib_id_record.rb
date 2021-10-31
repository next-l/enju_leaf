class NdlBibIdRecord < ApplicationRecord
  belongs_to :manifestation
end

# == Schema Information
#
# Table name: ndl_bib_id_records
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  manifestation_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
