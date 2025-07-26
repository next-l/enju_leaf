class NdlBibIdRecord < ApplicationRecord
  belongs_to :manifestation
  validates :body, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: ndl_bib_id_records
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  manifestation_id :bigint           not null
#
# Indexes
#
#  index_ndl_bib_id_records_on_body              (body) UNIQUE
#  index_ndl_bib_id_records_on_manifestation_id  (manifestation_id)
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_id => manifestations.id)
#
