require 'rails_helper'

describe ProduceType do
  it 'should create produce_type' do
    FactoryBot.create(:produce_type)
  end
end

# == Schema Information
#
# Table name: produce_types
#
#  id           :bigint           not null, primary key
#  display_name :text
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_produce_types_on_lower_name  (lower((name)::text)) UNIQUE
#
