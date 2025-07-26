require 'rails_helper'

describe Subscription do
  fixtures :subscriptions, :manifestations, :subscribes

  it "should_respond_to_subscribed" do
    subscriptions(:subscription_00001).subscribed(manifestations(:manifestation_00001)).should be_truthy
  end
end

# == Schema Information
#
# Table name: subscriptions
#
#  id               :bigint           not null, primary key
#  note             :text
#  subscribes_count :integer          default(0), not null
#  title            :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_list_id    :bigint
#  user_id          :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_order_list_id  (order_list_id)
#  index_subscriptions_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
