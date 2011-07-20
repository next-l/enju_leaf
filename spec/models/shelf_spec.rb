# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Shelf do
  fixtures :all

  it "should respond to web_shelf" do
    shelves(:shelf_00001).web_shelf?.should be_true
    shelves(:shelf_00002).web_shelf?.should_not be_true
  end
end

# == Schema Information
#
# Table name: shelves
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  library_id   :integer         default(1), not null
#  items_count  :integer         default(0), not null
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

