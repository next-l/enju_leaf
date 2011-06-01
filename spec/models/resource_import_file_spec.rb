# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ResourceImportFile do
  before(:each) do
    @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/examples/resource_import_file_sample1.tsv")
  end

  it "should be imported" do
    @file.import_start.should eq({:manifestation_imported => 7, :item_imported => 6, :manifestation_found => 4, :item_found => 3, :failed => 6})
    manifestation = Item.where(:item_identifier => '11111').first.manifestation
    manifestation.publishers.first.full_name.should eq 'test4'
    manifestation.publishers.first.full_name_transcription.should eq 'てすと4'
    manifestation.publishers.second.full_name_transcription.should eq 'てすと5'
  end
end
