# -*- encoding: utf-8 -*-
require 'spec_helper'

describe CheckoutStatHasUser do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: checkout_stat_has_users
#
#  id                    :integer         not null, primary key
#  user_checkout_stat_id :integer         not null
#  user_id               :integer         not null
#  checkouts_count       :integer         default(0), not null
#  created_at            :datetime
#  updated_at            :datetime
#

