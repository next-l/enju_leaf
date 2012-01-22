require 'spec_helper'

describe RealizeType do
  it 'should create realize_type' do
    FactoryGirl.create(:realize_type)
  end
end

# == Schema Information
#
# Table name: realize_types
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

