# -*- encoding: utf-8 -*-
require 'spec_helper'

describe CheckedItem do
  fixtures :all

  it "should respond to available_for_checkout?" do
    checked_items(:checked_item_00001).available_for_checkout?.should_not be_true
  end
end

# == Schema Information
#
# Table name: checked_items
#
#  id         :integer         not null, primary key
#  item_id    :integer         not null
#  basket_id  :integer         not null
#  due_date   :datetime        not null
#  created_at :datetime
#  updated_at :datetime
#

