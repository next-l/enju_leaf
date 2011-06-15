# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ResourceImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
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

  describe "when its mode is 'update'" do
    it "should update items" do
      @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/examples/item_update_file.tsv")
      @file.modify
      Item.where(:item_identifier => '00001').first.manifestation.creators.collect(&:full_name).should eq ['たなべ', 'こうすけ']
      Item.where(:item_identifier => '00001').first.manifestation.contributors.collect(&:full_name).should eq ['test1']
      Item.where(:item_identifier => '00002').first.manifestation.contributors.collect(&:full_name).should eq ['test2']
      Item.where(:item_identifier => '00003').first.manifestation.original_title.should eq 'テスト3'
    end
  end

  describe "when its mode is 'destroy'" do
    it "should remove items" do
      old_count = Item.count
      @file = ResourceImportFile.create :resource_import => File.new("#{Rails.root.to_s}/examples/item_delete_file.tsv")
      @file.remove
      Item.count.should eq old_count - 2
    end
  end
end
