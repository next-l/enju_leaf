# -*- encoding: utf-8 -*-
require 'spec_helper'

describe CheckedItem do
  fixtures :all
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

