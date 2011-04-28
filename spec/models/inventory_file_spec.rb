# -*- encoding: utf-8 -*-
require 'spec_helper'

describe InventoryFile do
  before(:each) do
    @file = InventoryFile.create :inventory => File.new("#{Rails.root.to_s}/examples/inventory_file_sample.tsv"), :user => Factory(:user)
  end

  it "should be imported" do
    @file.import.should be_true
  end
end
