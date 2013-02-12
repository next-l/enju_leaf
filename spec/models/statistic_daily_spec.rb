# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'database_cleaner'

describe Statistic do
  fixtures :all
#  fixtures :patron_types, :countries, :languages, :checkout_types, :circulation_statuses, :carrier_types, :roles, 
#           :user_groups, :user_group_has_checkout_types, :request_status_types, :carrier_type_has_checkout_types, 
#           :retention_periods, :manifestation_types, :user_statuses
  now = Time.now
  date = now.strftime("%Y%m%d")
  month = now.strftime("%Y%m")
  time_num = now.hour

  DatabaseCleaner.strategy = :truncation, {:except => %w[patron_types countries languages checkout_types circulation_statuses carrier_types roles user_groups user_group_has_checkout_types request_status_types carrier_type_has_checkout_types retention_periods manifestation_types user_statuses]}
  DatabaseCleaner.clean_with :truncation, {:except => %w[patron_types countries languages checkout_types circulation_statuses carrier_types roles user_groups user_group_has_checkout_types request_status_types carrier_type_has_checkout_types retention_periods manifestatioy_types user_statuses]}

  libraryA = FactoryGirl.create(:libraryA)
  libraryB = FactoryGirl.create(:libraryB)
  shelfA = Shelf.create(:name => "shelf_a", :library_id => libraryA.id)
  area1 = Area.create(:name => "area1", :address => "gotanda, shinagawa")
  area2 = Area.create(:name => "area2", :address => "shibuya, aoyama")
# create Users
  5.times do |i|
    tmps = []
    tmps << FactoryGirl.create(:adult_user) # libraryA
    tmps << FactoryGirl.create(:student_user) # libraryA
    tmps << FactoryGirl.create(:juniors_user) # libraryB
    tmps << FactoryGirl.create(:elements_user) # libraryB
    tmps << FactoryGirl.create(:children_user) # libraryB
    tmps.map{|user| user.patron.update_attributes(:address_1 => "gotanda 2-3")} if i == 1
    tmps.map{|user| user.patron.update_attributes(:address_1 => "aoyama 32")} if i == 2     
  end
  3.times do
    # not completely registed
    FactoryGirl.create(:has_not_user_number_user).update_attributes(:library_id => libraryB.id)
    # unavailable
    FactoryGirl.create(:locked_user).update_attributes(:library_id => libraryB.id)
  end
# create Items
  40.times do |i|
    FactoryGirl.create(:item_book).update_attributes(:shelf_id => libraryA.shelves.first.id, :call_number => "L#{i}|A|0#{i}")
    FactoryGirl.create(:item_serial).update_attributes(:shelf_id => shelfA.id)
  end
  15.times do |i|
    FactoryGirl.create(:item_book).update_attributes(:shelf_id => libraryB.shelves.first.id, :call_number => "L#{i}|B|0#{i}")
    FactoryGirl.create(:item_serial).update_attributes(:shelf_id => libraryB.shelves.first.id)
    FactoryGirl.create(:item_cd).update_attributes(:shelf_id => libraryA.shelves.first.id)
    FactoryGirl.create(:item_cd).update_attributes(:shelf_id => libraryB.shelves.first.id)
  end
  FactoryGirl.create(:missing_item).update_attributes(:shelf_id => libraryA.shelves.first.id)
  2.times {FactoryGirl.create(:missing_item).update_attributes(:shelf_id => libraryB.shelves.first.id)}
# create Checkouts
  20.times do |i|
    FactoryGirl.create(:adult_checkout).item.manifestation.update_attributes(:ndc => "#{i}7777") # libraryA, general books
  end
  11.times do |i|
    FactoryGirl.create(:student_checkout).item.manifestation.update_attributes(:ndc => "A0000#{i}") # libraryB, other books
    FactoryGirl.create(:juniors_checkout).item.manifestation.update_attributes(:ndc => "#{i}8888") # libraryA, general books
    FactoryGirl.create(:elements_checkout).item.manifestation.update_attributes(:ndc => "E0000#{i}") # libraryB, books for children
    FactoryGirl.create(:children_checkout).item.manifestation.update_attributes(:ndc => "K0000#{i}") # libraryA, books for children
  end
# create Reminders
  Checkout.where("id < 6").each do |checkout|
    FactoryGirl.build(:reminder_list).update_attributes(:item_identifier => checkout.item.item_identifier, :checkout_id => checkout.id)
  end
# checkin
  Checkout.all.map{|c| checkin = FactoryGirl.build(:checkin_libraryA); checkin.item_id = c.item_id; checkin.save!; c.checkin_id = checkin.id; c.save!}
# create Reserves
  2.times do
    FactoryGirl.create(:reserve_by_user)
  end
  FactoryGirl.create(:reserve_by_librarian)
# create Questions (reference)
  FactoryGirl.create(:question_libraryA)
  FactoryGirl.create(:question_libraryB)
# create LibraryReport
  LibraryReport.create(:yyyymm => month, :yyyymmdd => date, :library_id => libraryA.id, :visiters => 30, :copies => 3, :consultations => 2)
  LibraryReport.create(:yyyymm => month, :yyyymmdd => date, :library_id => libraryB.id, :visiters => 24, :copies => 2, :consultations => 5)
# create Event
  FactoryGirl.build(:closing_day).update_attributes(:start_at => now, :end_at => now+2.days, :library_id => libraryA.id)
# create InterLibraryloan
  InterLibraryLoan.create(:from_library_id => libraryA.id, :to_library_id => libraryB.id, :item_id => Item.first.id, :reason => 1, :shipped_at => date, :received_at => date)
  InterLibraryLoan.create(:from_library_id => libraryA.id, :to_library_id => libraryB.id, :item_id => Item.first.id, :reason => 2, :shipped_at => date, :received_at => date)
  InterLibraryLoan.create(:from_library_id => libraryB.id, :to_library_id => libraryA.id, :item_id => Item.first.id, :reason => 1, :shipped_at => date, :received_at => date)
  InterLibraryLoan.create(:from_library_id => libraryB.id, :to_library_id => libraryA.id, :item_id => Item.first.id, :reason => 2, :shipped_at => date, :received_at => date)

  Statistic.calc_sum(date)
  Statistic.calc_sum(month, true)

# number of items in all libraries
  it "number of items in all libraries" do
    data_type = 211
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 143
    data_type = 111; checkout_type_id = CheckoutType.find_by_name('book').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type_id).first.value.should == 58
    data_type = 111; checkout_type_id = CheckoutType.find_by_name('serial').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type_id).first.value.should == 55
    data_type = 111; checkout_type_id = CheckoutType.find_by_name('cd').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type_id).first.value.should == 30
    data_type = 111; option = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 3
    data_type = 111; call_number = "A"
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :call_number => call_number).first.value.should == 40
    data_type = 111; call_number = "B"
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :call_number => call_number).first.value.should == 15
  end

# number of items in libraryA
  it "number of items in libraryA" do
    data_type = 211; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 96
    data_type = 111; library_id = libraryA.id;checkout_type_id = CheckoutType.find_by_name('book').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :checkout_type_id => checkout_type_id).first.value.should == 41
    data_type = 111; library_id = libraryA.id;checkout_type_id = CheckoutType.find_by_name('serial').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :checkout_type_id => checkout_type_id).first.value.should == 40
    data_type = 111; library_id = libraryA.id;checkout_type_id = CheckoutType.find_by_name('cd').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :checkout_type_id => checkout_type_id).first.value.should == 15
    data_type = 111; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 1
    data_type = 111; library_id = libraryA.id; call_number = "A"
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :call_number => call_number).first.value.should == 40
    data_type = 111; library_id = libraryA.id; call_number = "B"
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :call_number => call_number).should be_empty
  end

# number of items in libraryB
  it "number of items in libraryB" do
    data_type = 211; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).first.value.should == 47
    data_type = 111; library_id = libraryB.id;checkout_type_id = CheckoutType.find_by_name('book').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :checkout_type_id => checkout_type_id).first.value.should == 17
    data_type = 111; library_id = libraryB.id;checkout_type_id = CheckoutType.find_by_name('serial').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :checkout_type_id => checkout_type_id).first.value.should == 15
    data_type = 111; library_id = libraryB.id;checkout_type_id = CheckoutType.find_by_name('cd').id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :checkout_type_id => checkout_type_id).first.value.should == 15
    data_type = 111; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 2
    data_type = 111; library_id = libraryB.id; call_number = "A"
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :call_number => call_number).should be_empty
    data_type = 111; library_id = libraryB.id; call_number = "B"
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :call_number => call_number).first.value.should == 15
  end

# number of users in all libraries
  it "number of users in all libraries" do
    data_type = 112
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 31
    data_type = 112; user_type = 5
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 5
    data_type = 112; user_type = 4
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 5
    data_type = 112; user_type = 3
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 5
    data_type = 112; user_type = 2
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 5
    data_type = 112; user_type = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 5
    data_type = 212; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 10
    data_type = 262; age = 0; area_id = area1.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age, :area_id => area_id).first.value.should == 2
    data_type = 212; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 10
    data_type = 262; age = 1; area_id = area1.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age, :area_id => area_id).first.value.should == 2
    data_type = 212; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 5
    data_type = 262; age = 2; area_id = area2.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age, :area_id => area_id).first.value.should == 1
    data_type = 112; option = 1 # available
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 28
    data_type = 112; option = 2 # unavailable
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 3
    data_type = 112; option = 3 # no user_number
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 3
  end

# number of users in libraryA
  it "number of users in libraryA" do
    data_type = 112;library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 10
    data_type = 112;library_id = libraryA.id; user_type = 5
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 5
    data_type = 112;library_id = libraryA.id; user_type = 4
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 5
    data_type = 112;library_id = libraryA.id; user_type = 3
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 112;library_id = libraryA.id; user_type = 2
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 112;library_id = libraryA.id; user_type = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 212; library_id = libraryA.id; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 262; library_id = libraryA.id; age = 0; area_id = area1.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age, :area_id => area_id).first.value.should == 2
    data_type = 212; library_id = libraryA.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 5
    data_type = 262; library_id = libraryA.id; age = 1; area_id = area1.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age, :area_id => area_id).first.value.should == 1
    data_type = 212; library_id = libraryA.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 5
    data_type = 262; library_id = libraryA.id; age = 2; area_id = area2.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age, :area_id => area_id).first.value.should == 1
    data_type = 112;library_id = libraryA.id; option = 1 # available
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 10
    data_type = 112;library_id = libraryA.id; option = 2 # unavailable
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
    data_type = 112;library_id = libraryA.id;  option = 3 # no user_number
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
  end

# number of users in libraryB
  it "number of users in libraryB" do
    data_type = 112;library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 21
    data_type = 112;library_id = libraryB.id; user_type = 5
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 112;library_id = libraryB.id; user_type = 4
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 112;library_id = libraryB.id; user_type = 3
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 5
    data_type = 112;library_id = libraryB.id; user_type = 2
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 5
    data_type = 112; library_id = libraryB.id; user_type = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 5
    data_type = 212; library_id = libraryB.id; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 10
    data_type = 262; library_id = libraryB.id; age = 0; area_id = area1.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age, :area_id => area_id).first.value.should == 2
    data_type = 212; library_id = libraryB.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 5
    data_type = 262; library_id = libraryB.id; age = 1; area_id = area1.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age, :area_id => area_id).first.value.should == 1
    data_type = 212; library_id = libraryB.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 262; library_id = libraryB.id; age = 2; area_id = area2.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age, :area_id => area_id).should be_empty
    data_type = 112; library_id = libraryB.id; option = 1 # available
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 18
    data_type = 112; library_id = libraryB.id; option = 2 # unavailable
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 3
    data_type = 112; library_id = libraryB.id;  option = 3 # no user_number
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 3
  end

# number of checkout users in all libraries
  it "number of checkout users in all libraries" do
    data_type = 222
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 5
    data_type = 322
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => time_num).first.value.should == 5
    data_type = 322
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => time_num-2).should be_empty
    data_type = 222; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 2
    data_type = 222; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 2
    data_type = 222; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 1
  end
  it "number of checkout adults in all libraries" do
    data_type = 222; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 1
    data_type = 322; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout students in all libraries" do
    data_type = 222; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 1
    data_type = 322; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout juniors in all libraries" do
    data_type = 222; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 1
    data_type = 322; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout elementaries in all libraries" do
    data_type = 222; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 1
    data_type = 322; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout children in all libraries" do
    data_type = 222; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type).first.value.should == 1
    data_type = 322; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :user_type => user_type, :hour => 24-time_num).should be_empty
  end

# number of checkout users in libraryA
  it "number of checkout users in libraryA" do
    data_type = 222; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 3
    data_type = 322; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 3
    data_type = 322; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
    data_type = 222; library_id = libraryA.id; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 222; library_id = libraryA.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 1
    data_type = 222; library_id = libraryA.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 1
  end
  it "number of checkout adults in libraryA" do
    data_type = 222; library_id = libraryA.id; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 1
    data_type = 322; library_id = libraryA.id; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; library_id = libraryA.id; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout students in libraryA" do
    data_type = 222; library_id = libraryA.id; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 322; library_id = libraryA.id; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).should be_empty
    data_type = 322; library_id = libraryA.id; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout juniors in libraryA" do
    data_type = 222; library_id = libraryA.id; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 1
    data_type = 322; library_id = libraryA.id; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; library_id = libraryA.id; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout elementaries in libraryA" do
    data_type = 222; library_id = libraryA.id; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 322; library_id = libraryA.id; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).should be_empty
    data_type = 322; library_id = libraryA.id; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout children in libraryA" do
    data_type = 222; library_id = libraryA.id; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 1
    data_type = 322; library_id = libraryA.id; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; library_id = libraryA.id; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end

# number of checkout users in libraryB
  it "number of checkout users in libraryB" do
    data_type = 222; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).first.value.should == 2
    data_type = 322; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 2
    data_type = 322; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
    data_type = 222; library_id = libraryB.id; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 2
    data_type = 222; library_id = libraryB.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 1
    data_type = 222; library_id = libraryB.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
  end
  it "number of checkout adults in libraryB" do
    data_type = 222; library_id = libraryB.id; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 322; library_id = libraryB.id; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).should be_empty
    data_type = 322; library_id = libraryB.id; user_type = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout students in libraryB" do
    data_type = 222; library_id = libraryB.id; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 1
    data_type = 322; library_id = libraryB.id; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; library_id = libraryB.id; user_type = 4
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout juniors in libraryB" do
    data_type = 222; library_id = libraryB.id; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 322; library_id = libraryB.id; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).should be_empty
    data_type = 322; library_id = libraryB.id; user_type = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout elementaries in libraryB" do
    data_type = 222; library_id = libraryB.id; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).first.value.should == 1
    data_type = 322; library_id = libraryB.id; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).first.value.should == 1
    data_type = 322; library_id = libraryB.id; user_type = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => 24-time_num).should be_empty
  end
  it "number of checkout children in libraryB" do
    data_type = 222; library_id = libraryB.id; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type).should be_empty
    data_type = 322; library_id = libraryB.id; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).should be_empty
    data_type = 322; library_id = libraryB.id; user_type = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :user_type => user_type, :hour => time_num).should be_empty
  end

# number of checkouts in all libraries
  it "number of checkouts in all libraries" do
    data_type = 221
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 64
    data_type = 321
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => time_num).first.value.should == 64
    data_type = 321
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => 24-time_num).should be_empty
    data_type = 121; user_group_id = 2
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_group_id => user_group_id).first.value.should == 64
    data_type = 121; user_group_id = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => 0, :user_group_id => user_group_id).should be_empty
    data_type = 221; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 22
    data_type = 221; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 22
    data_type = 221; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 20
  end
  it "number of checkouts of general books in all libraries" do
    data_type = 221; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil).first.value.should == 31
    data_type = 321; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil, :hour => time_num).first.value.should == 31
    data_type = 321; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; option = 1; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
    data_type = 221; option = 1; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).first.value.should == 11
    data_type = 221; option = 1; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).first.value.should == 20
  end
  it "number of checkouts of books for children in all libraries" do
    data_type = 221; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil).first.value.should == 22
    data_type = 321; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil, :hour => time_num).first.value.should == 22
    data_type = 321; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; option = 2; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).first.value.should == 22
    data_type = 221; option = 2; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
    data_type = 221; option = 2; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
  end
  it "number of checkouts of other books in all libraries" do
    data_type = 221; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil).first.value.should == 11
    data_type = 321; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil, :hour => time_num).first.value.should == 11
    data_type = 321; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; option = 3; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
    data_type = 221; option = 3; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).first.value.should == 11
    data_type = 221; option = 3; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
  end

# number of checkouts in libraryA
  it "number of checkouts in libraryA" do
    data_type = 221; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 42
    data_type = 321; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 42
    data_type = 321; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
    data_type = 121; library_id = libraryA.id; user_group_id = 2
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_group_id => user_group_id).first.value.should == 42
    data_type = 121; library_id = libraryA.id; user_group_id = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_group_id => user_group_id).should be_empty
    data_type = 221; library_id = libraryA.id; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryA.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryA.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 20
  end
  it "number of checkouts of general books in libraryA" do
    data_type = 221; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil).first.value.should == 31
    data_type = 321; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => time_num).first.value.should == 31
    data_type = 321; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; library_id = libraryA.id; option = 1; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 1; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryA.id; option = 1; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).first.value.should == 20
  end
  it "number of checkouts of books for children in libraryA" do
    data_type = 221; library_id = libraryA.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil).first.value.should == 11
    data_type = 321; library_id = libraryA.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => time_num).first.value.should == 11
    data_type = 321; library_id = libraryA.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; library_id = libraryA.id; option = 2; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryA.id; option = 2; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 2; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
  end
  it "number of checkouts of other books in libraryA" do
    data_type = 221; library_id = libraryA.id; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil).should be_empty
    data_type = 321; library_id = libraryA.id; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => time_num).should be_empty
    data_type = 321; library_id = libraryA.id; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; library_id = libraryA.id; option = 3; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 3; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 3; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
  end

# number of checkouts in libraryB
  it "number of checkouts in libraryB" do
    data_type = 221; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 22
    data_type = 321; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 22
    data_type = 321; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
    data_type = 121; library_id = libraryB.id; user_group_id = 2
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_group_id => user_group_id).first.value.should == 22
    data_type = 121; library_id = libraryB.id; user_group_id = 1
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id, :user_group_id => user_group_id).should be_empty
    data_type = 221; library_id = libraryB.id; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryB.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryB.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
  end
  it "number of checkouts of general books in libraryB" do
    data_type = 221; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil).should be_empty
    data_type = 321; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => time_num).should be_empty
    data_type = 321; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; library_id = libraryB.id; option = 1; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryB.id; option = 1; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryB.id; option = 1; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
  end
  it "number of checkouts of books for children in libraryB" do
    data_type = 221; library_id = libraryB.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil).first.value.should == 11
    data_type = 321; library_id = libraryB.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => time_num).first.value.should == 11
    data_type = 321; library_id = libraryB.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; library_id = libraryA.id; option = 2; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).first.value.should == 11
    data_type = 221; library_id = libraryA.id; option = 2; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 2; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
  end
  it "number of checkouts of other books in libraryB" do
    data_type = 221; library_id = libraryB.id; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil).first.value.should == 11
    data_type = 321; library_id = libraryB.id; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => time_num).first.value.should == 11
    data_type = 321; library_id = libraryB.id; option = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => nil, :hour => 24-time_num).should be_empty
    data_type = 221; library_id = libraryA.id; option = 3; age = 0
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 3; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 221; library_id = libraryA.id; option = 3; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
  end

# number of reminders
  it "number of reminders in all libraries" do
    data_type = 221; option = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 5
  end
  it "number of reminders in libraryA" do
    data_type = 221; library_id = libraryA.id; option = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 5
  end
  it "number of reminders in libraryB" do
    data_type = 221; library_id = libraryB.id; option = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
  end
  
# number of checkins
  it "number of checkins in all libraries" do
    data_type = 251
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 64
  end
  it "number of checkins in libraryA" do
    data_type = 251; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 64
  end
  it "number of checkins in libraryB" do
    data_type = 251; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.should be_empty
  end

# number of checkins after reminder
  it "number of checkins after reminder in all libraries" do
    data_type = 251; option  = 5 
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 5
  end
  it "number of checkins after reminder in libraryA" do
    data_type = 251; library_id = libraryA.id; option = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 5
  end
  it "number of checkins after reminder in libraryB" do
    data_type = 251; library_id = libraryB.id; option = 5
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
  end

# number of reserves
  it "number of reserves in all libraries" do
    data_type = 233
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 3
    data_type = 233; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 3
    data_type = 233; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).should be_empty
    data_type = 333
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => time_num).first.value.should == 3
    data_type = 333
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => 24-time_num).should be_empty
  end
  it "number of reserves on counter in all libraries" do
    data_type = 233; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 1
    data_type = 233; option = 1; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).first.value.should == 1
    data_type = 233; option = 1; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
    data_type = 333; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :hour => time_num).first.value.should == 1
    data_type = 333; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :hour => 24-time_num).should be_empty
  end
  it "number of reserves on OPAC in all libraries" do
    data_type = 233; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option).first.value.should == 2
    data_type = 233; option = 2; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).first.value.should == 2
    data_type = 233; option = 2; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :age => age).should be_empty
    data_type = 333; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :hour => time_num).first.value.should == 2
    data_type = 333; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :option => option, :hour => 24-time_num).should be_empty
  end
  it "number of reserves in libraryA" do
    data_type = 233; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).first.value.should == 2
    data_type = 233; library_id = libraryA.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 2
    data_type = 233; library_id = libraryA.id; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 333; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 2
    data_type = 333; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
  end
  it "number of reserves on counter in libraryA" do
    data_type = 233; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
    data_type = 233; library_id = libraryA.id; option = 1; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 233; library_id = libraryA.id; option = 1; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 333; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => time_num).should be_empty
    data_type = 333; library_id = libraryA.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => 24-time_num).should be_empty
  end
  it "number of reserves on OPAC in libraryA" do
    data_type = 233; library_id = libraryA.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 2
    data_type = 233; library_id = libraryA.id; option = 2; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).first.value.should == 2
    data_type = 233; library_id = libraryA.id; option = 2; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 333; library_id = libraryA.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => time_num).first.value.should == 2
    data_type = 333; library_id = libraryA.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => 24-time_num).should be_empty
  end
  it "number of reserves in libraryB" do
    data_type = 233; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).first.value.should == 1
    data_type = 233; library_id = libraryB.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 1
    data_type = 233; library_id = libraryB.id; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 333; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 1
    data_type = 333; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
  end
  it "number of reserves on counter in libraryB" do
    data_type = 233; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).first.value.should == 1
    data_type = 233; library_id = libraryB.id; option = 1; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).first.value.should == 1
    data_type = 233; library_id = libraryB.id; option = 1; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 333; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => time_num).first.value.should == 1
    data_type = 333; library_id = libraryB.id; option = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => 24-time_num).should be_empty
  end
  it "number of reserves on OPAC in libraryB" do
    data_type = 233; library_id = libraryB.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option).should be_empty
    data_type = 233; library_id = libraryB.id; option = 2; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 233; library_id = libraryB.id; option = 2; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :age => age).should be_empty
    data_type = 333; library_id = libraryB.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => time_num).should be_empty
    data_type = 333; library_id = libraryB.id; option = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :option => option, :hour => 24-time_num).should be_empty
  end

# number of references
  it "number of references in all libraries" do
    data_type = 243
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 2
    data_type = 243; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 1
    data_type = 243; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).first.value.should == 1
    data_type = 243; age = 3
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :age => age).should be_empty
    data_type = 343
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => time_num).first.value.should == 2
    data_type = 343
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0, :hour => 24-time_num).should be_empty
  end
  it "number of references in libraryA" do
    data_type = 243; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 1
    data_type = 243; library_id = libraryA.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 243; library_id = libraryA.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 1
    data_type = 343; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 1
    data_type = 343; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
  end
  it "number of references in libraryB" do
    data_type = 243; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).no_condition.first.value.should == 1
    data_type = 243; library_id = libraryB.id; age = 1
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).first.value.should == 1
    data_type = 243; library_id = libraryB.id; age = 2
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :age => age).should be_empty
    data_type = 343; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => time_num).first.value.should == 1
    data_type = 343; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id, :hour => 24-time_num).should be_empty
  end

# number of counter users
  it "number of counter users in all libraries" do
    pending
  end
  it "number of counter users in libraryA" do
    pending
  end
  it "number of counter users in libraryB" do
    pending
  end

# number of consultations
  it "number of consultaions" do
    data_type = 214
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => 0).no_condition.first.value.should == 7
    data_type = 214; library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).first.value.should == 2
    data_type = 214; library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => library_id).first.value.should == 5
  end

# number of visiters
  it "number of visiters" do
    data_type = 116; library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).first.value.should == 30
    data_type = 116; library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).first.value.should == 24
  end

# number of copies
  it "number of copies" do
    data_type = 115; library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).first.value.should == 3
    data_type = 115; library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).first.value.should == 2
  end

# number of open days
  it "number of open days" do
    data_type = 113; library_id = libraryA.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).first.value.should == 28
    data_type = 113; library_id = libraryB.id
    Statistic.where(:yyyymm => month, :data_type => data_type, :library_id => library_id).first.value.should == 31
  end

# number of inter library loans
  it "number of inter library loans" do
    data_type = 261; from_library_id = libraryA.id; to_library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => from_library_id, :borrowing_library_id => to_library_id).first.value.should == 1
    data_type = 262; from_library_id = libraryA.id; to_library_id = libraryB.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => from_library_id, :borrowing_library_id => to_library_id).first.value.should == 1
    data_type = 261; from_library_id = libraryB.id; to_library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => from_library_id, :borrowing_library_id => to_library_id).first.value.should == 1
    data_type = 262; from_library_id = libraryB.id; to_library_id = libraryA.id
    Statistic.where(:yyyymmdd => date, :data_type => data_type, :library_id => from_library_id, :borrowing_library_id => to_library_id).first.value.should == 1
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
