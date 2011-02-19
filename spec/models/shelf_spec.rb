# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Shelf do
  fixtures :all

  it "should respond to web_shelf" do
    shelves(:shelf_00001).web_shelf?.should be_true
    shelves(:shelf_00002).web_shelf?.should_not be_true
  end
end
