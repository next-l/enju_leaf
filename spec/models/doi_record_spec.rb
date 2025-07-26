require 'rails_helper'

RSpec.describe DoiRecord, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: doi_records
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  manifestation_id :bigint           not null
#
# Indexes
#
#  index_doi_records_on_lower_body_manifestation_id  (lower((body)::text), manifestation_id) UNIQUE
#  index_doi_records_on_manifestation_id             (manifestation_id)
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_id => manifestations.id)
#
