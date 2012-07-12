# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'database_cleaner'

describe Statistic do
  fixtures :patron_types, :countries, :languages, :checkout_types, :circulation_statuses, :carrier_types, :roles, :user_groups, :user_group_has_checkout_types, :request_status_types, :carrier_type_has_checkout_types

  DatabaseCleaner.strategy = :truncation, {:except => %w[patron_types countries languages checkout_types circulation_statuses carrier_types roles user_groups user_group_has_checkout_types request_status_types carrier_type_has_checkout_types]}
  DatabaseCleaner.clean_with :truncation, {:except => %w[patron_types countries languages checkout_types circulation_statuses carrier_types roles user_groups user_group_has_checkout_types request_status_types carrier_type_has_checkout_types]}

  libraryA = FactoryGirl.create(:libraryA)
  libraryB = FactoryGirl.create(:libraryB)
  shelfA = Shelf.create(:name => "shelf_a", :library_id => libraryA.id)

  date = 20120401
  month = 201204

  # create Users
  5.times do |i|
    FactoryGirl.create(:adult_user) # libraryA
    FactoryGirl.create(:student_user) # libraryA
    FactoryGirl.create(:juniors_user) # libraryB
    FactoryGirl.create(:elements_user) # libraryB
    FactoryGirl.create(:children_user) # libraryB
  end
  # create Items
  200.times do |i|
    FactoryGirl.create(:item_book).update_attributes(:shelf_id => libraryA.shelves.first.id, :call_number => "L#{i}|A|0#{i}")
  end
  30.times do |i|
    FactoryGirl.create(:item_serial).update_attributes(:shelf_id => shelfA.id)
    FactoryGirl.create(:item_book).update_attributes(:shelf_id => libraryB.shelves.first.id, :call_number => "L#{i}|B|0#{i}")
    FactoryGirl.create(:item_serial).update_attributes(:shelf_id => libraryB.shelves.first.id)
    FactoryGirl.create(:item_cd).update_attributes(:shelf_id => libraryA.shelves.first.id)
    FactoryGirl.create(:item_cd).update_attributes(:shelf_id => libraryB.shelves.first.id)
  end
  FactoryGirl.create(:missing_item).update_attributes(:shelf_id => libraryA.shelves.first.id)
  2.times {FactoryGirl.create(:missing_item).update_attributes(:shelf_id => libraryB.shelves.first.id)}
 
  30.times do |j|
    date_s = Time.parse((date+j).to_s)
    p date_s
    # create Checkouts
    tmp = []
    5.times do |i|
      checkout = FactoryGirl.create(:adult_checkout)
      checkout.item.manifestation.update_attributes(:ndc => "#{i}7777") # libraryA, general books
      tmp << checkout
    end
    checkout = FactoryGirl.create(:student_checkout)
    checkout.item.manifestation.update_attributes(:ndc => "A0000#{j}") # libraryB, other books
    tmp << checkout
    checkout = FactoryGirl.create(:juniors_checkout)
    checkout.item.manifestation.update_attributes(:ndc => "8888#{j}") # libraryA, general books
    tmp << checkout
    checkout = FactoryGirl.create(:elements_checkout)
    checkout.item.manifestation.update_attributes(:ndc => "E0000#{j}") # libraryB, books for children
    tmp << checkout
    checkout = FactoryGirl.create(:children_checkout)
    checkout.item.manifestation.update_attributes(:ndc => "K0000#{j}") # libraryA, books for children
    tmp << checkout
    tmp.map{|c| c.update_attributes(:created_at => date_s)}   
    # checkin
    tmp.map{|c| checkin = FactoryGirl.build(:checkin_libraryA); checkin.item_id = c.item_id; checkin.save!; c.checkin_id = checkin.id; c.checkin.update_attributes(:created_at => date_s)}
    
    Statistic.calc_sum(date_s.strftime("%Y%m%d"))
  end
  Statistic.calc_sum(month.to_s, true)

# average of checkout users
  it "average of checkout users" do
    data_type = 122; option = 4
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 5
    library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 3
    library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 2
  end

# average of checkouts
  it "average of checkouts" do
    data_type = 121; option = 4
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 9
    library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 7
    library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 2
  end

# average of checkins
  it "average of checkins" do
    data_type = 151; option = 4
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 9
    library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 9
    library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
  end

end

# == Schema Information
#
# Table name: statistics
#

#  name         :string(255)     not null

#  id           :integer         not null default nextval('statistics_id_seq'::regclass)
#  yyyymmdd     :integer
#  yyyymm       :integer
#  dd           :integer
#  data_type    :integer
#  library_id   :integer         default 0
#  value        :integer
#  created_at   :datetime
#  updated_at   :datetime
#  hour         :integer
#  day          :integer
#  checkout_type_id  :integer
#  shelf_id     :integer
#  ndc          :string(255)
#  call_number  :string(255)
#  age          :integer
#  option       :integer         default 0
#  user_group_id     :integer
#  area_id      :integer         default 0
#  user_type    :integer
#  borrowing_library_id  :integer  default 0
#  user_id      :integer
