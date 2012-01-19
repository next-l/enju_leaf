require 'spec_helper'

describe ProduceType do
  it 'should create produce_type' do
    FactoryGirl.create(:produce_type)
  end
end

# == Schema Information
#
# Table name: produce_types
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

