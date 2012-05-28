# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Basket do
  fixtures :all

  it "should not create basket when user is not active" do
    basket = Basket.new
    basket.user = users(:user4)
    basket.save.should be_false
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  note         :text
#  lock_version :integer         default(0), not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

