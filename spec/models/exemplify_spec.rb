# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Exemplify do
  fixtures :all

  before(:each) do
    @exemplify = FactoryGirl.create(:exemplify)
  end

  it 'should create lending policy' do
    @exemplify.item.lending_policies.size.should eq 3
    periods = UserGroupHasCheckoutType.available_for_item(@exemplify.item).order('user_group_has_checkout_types.id').collect(&:checkout_period)
    @exemplify.item.lending_policies.order('lending_policies.id').collect(&:loan_period).should eq periods
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

