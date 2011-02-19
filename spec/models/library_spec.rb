# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Library do
  before(:each) do
    @library = Factory(:library)
  end

  it "should should create default shelf" do
    @library.shelves.first.should be_true
    @library.shelves.first.name.should eq "#{@library.name}_default"
  end
end
