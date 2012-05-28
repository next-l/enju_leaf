# -*- encoding: utf-8 -*-
require 'spec_helper'

describe InventoryFile do
  fixtures :users

  before(:each) do
    @file = InventoryFile.new :inventory => File.new("#{Rails.root.to_s}/examples/inventory_file_sample.tsv")
    @file.user = users(:admin)
    @file.save
  end

  it "should be imported" do
    @file.import.should be_true
  end
end
# == Schema Information
#
# Table name: inventory_files
#
#  id                     :integer         not null, primary key
#  filename               :string(255)
#  content_type           :string(255)
#  size                   :integer
#  file_hash              :string(255)
#  user_id                :integer
#  note                   :text
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  inventory_file_name    :string(255)
#  inventory_content_type :string(255)
#  inventory_file_size    :integer
#  inventory_updated_at   :datetime
#  inventory_fingerprint  :string(255)
#  error_message          :text
#

