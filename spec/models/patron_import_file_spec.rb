# -*- encoding: utf-8 -*-
require 'spec_helper'

describe PatronImportFile do
  #pending "add some examples to (or delete) #{__FILE__}"
  before(:each) do
    @file = PatronImportFile.create! :patron_import => File.new("#{Rails.root.to_s}/examples/patron_import_file_sample1.tsv")
  end

  it "should be imported" do
    @file.state.should eq 'pending'
    @file.import_start.should eq({:patron_imported=>3, :user_imported=>2, :failed=>0})
  end
end
