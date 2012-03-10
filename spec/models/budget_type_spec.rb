# -*- encoding: utf-8 -*-
require 'spec_helper'

describe BudgetType do
  it 'should create budget_type' do
    FactoryGirl.create(:budget_type)
  end
end

# == Schema Information
#
# Table name: budget_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

