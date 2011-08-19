# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Exemplify do
  fixtures :all

  before(:each) do
    @exemplify = FactoryGirl.create(:exemplify)
  end

  it 'should create lending policy' do
    @exemplify.create_lending_policy
  end
end

# == Schema Information
#
# Table name: exemplifies
#
#  id               :integer         not null, primary key
#  manifestation_id :integer         not null
#  item_id          :integer         not null
#  type             :string(255)
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#

