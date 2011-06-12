# -*- encoding: utf-8 -*-
require 'spec_helper'

describe PatronImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = PatronImportFile.create! :patron_import => File.new("#{Rails.root.to_s}/examples/patron_import_file_sample1.tsv")
    end

    it "should be imported" do
      @file.state.should eq 'pending'
      @file.import_start.should eq({:patron_imported => 3, :user_imported => 2, :failed => 0})
    end
  end

  describe "when its mode is 'destroy'" do
    it "should remove users" do
      old_count = User.count
      @file = PatronImportFile.create :patron_import => File.new("#{Rails.root.to_s}/examples/user_delete_file.tsv")
      @file.remove
      User.count.should eq old_count - 3
    end
  end
end
