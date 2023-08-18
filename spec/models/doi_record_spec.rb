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
#  manifestation_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
