# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Basket do
  fixtures :all

  it "should not create basket when user is not active" do
    Basket.create(:user => users(:user4)).id.should be_nil
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  note         :text
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

