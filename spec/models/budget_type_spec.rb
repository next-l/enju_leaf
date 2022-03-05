# -*- encoding: utf-8 -*-
require 'rails_helper'

describe BudgetType do
  it 'should create budget_type' do
    FactoryBot.create(:budget_type)
  end
end

# == Schema Information
#
# Table name: budget_types
#
#  id           :integer          not null, primary key
#  name         :string
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
