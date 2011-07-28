# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Subscription do
  fixtures :subscriptions, :manifestations, :subscribes

  it "should_respond_to_subscribed" do
    subscriptions(:subscription_00001).subscribed(manifestations(:manifestation_00001)).should be_true
  end
end

# == Schema Information
#
# Table name: subscriptions
#
#  id               :integer         not null, primary key
#  title            :text            not null
#  note             :text
#  user_id          :integer
#  order_list_id    :integer
#  deleted_at       :datetime
#  subscribes_count :integer         default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#

