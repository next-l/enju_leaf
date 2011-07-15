# -*- encoding: utf-8 -*-
require 'spec_helper'

describe LendingPolicy do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: lending_policies
#
#  id             :integer         not null, primary key
#  item_id        :integer         not null
#  user_group_id  :integer         not null
#  loan_period    :integer         default(0), not null
#  fixed_due_date :datetime
#  renewal        :integer         default(0), not null
#  fine           :decimal(, )     default(0.0), not null
#  note           :text
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

