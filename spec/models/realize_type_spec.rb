require 'rails_helper'

describe RealizeType do
  it 'should create realize_type' do
    FactoryBot.create(:realize_type)
  end
end

# == Schema Information
#
# Table name: realize_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
