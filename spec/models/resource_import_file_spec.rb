# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ResourceImportFile do
  before(:each) do
    @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/examples/resource_import_file_sample1.tsv")
  end

  it "should be imported" do
    @file.import_start.should eq({:manifestation_imported=>7, :item_imported=>6, :manifestation_found=>4, :item_found=>3, :failed=>6})
  end
end
