# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Library do
  fixtures :all

  before(:each) do
    @library = FactoryGirl.create(:library)
  end

  it "should should create default shelf" do
    @library.shelves.first.should be_true
    @library.shelves.first.name.should eq "#{@library.name}_default"
  end
end

# == Schema Information
#
# Table name: libraries
#
#  id                    :integer         not null, primary key
#  name                  :string(255)     not null
#  display_name          :text
#  short_display_name    :string(255)     not null
#  zip_code              :string(255)
#  street                :text
#  locality              :text
#  region                :text
#  telephone_number_1    :string(255)
#  telephone_number_2    :string(255)
#  fax_number            :string(255)
#  note                  :text
#  call_number_rows      :integer         default(1), not null
#  call_number_delimiter :string(255)     default("|"), not null
#  library_group_id      :integer         default(1), not null
#  users_count           :integer         default(0), not null
#  position              :integer
#  country_id            :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  deleted_at            :datetime
#  opening_hour          :text
#  latitude              :float
#  longitude             :float
#  isil                  :string(255)
#

