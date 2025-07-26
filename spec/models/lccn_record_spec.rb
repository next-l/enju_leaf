require 'rails_helper'

RSpec.describe LccnRecord, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: lccn_records
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  manifestation_id :bigint           not null
#
# Indexes
#
#  index_lccn_records_on_body              (body) UNIQUE
#  index_lccn_records_on_manifestation_id  (manifestation_id)
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_id => manifestations.id)
#
