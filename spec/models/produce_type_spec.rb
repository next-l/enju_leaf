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
#  id           :integer          not null, primary key
#  name         :string
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
