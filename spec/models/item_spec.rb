# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Item do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  describe 'validates' do
    describe '' do
      it '' # TODO
      # validates_associated :circulation_status, :shelf, :bookstore, :checkout_type, :retention_period
    end
    describe '' do
      it '' # TODO
      # validates_presence_of :circulation_status, :checkout_type, :retention_period, :rank
    end
    describe '' do
      it '' # TODO: immediately
      # validate :is_original?, :if => proc{ SystemConfiguration.get("manifestation.manage_item_rank") }
    end
  end

  describe 'before_save' do
    it '' # TODO: immediately
    # before_save :set_use_restriction, :set_retention_period, :check_remove_item, :except => :delete
    it '' # TODO: immediately
    # before_save :set_rank, :unless => proc{ SystemConfiguration.get("manifestation.manage_item_rank") }
  end

  describe 'after_save' do
    it '' # TODO: immediately
    # after_save :check_price, :except => :delete
    it '' # TODO
    # after_save :reindex
  end

  describe '#serach' do
    it '' # TODO: immediately
  end

  describe '#reindex' do
    it '' # TODO
  end

  describe '#set_circulation_status' do
    it '' # TODO: immediately
  end

  describe '#set_use_restriction' do
    it '' # TODO: immediately
  end

  describe '#checkout_status' do
    it '' # TODO: immediately
  end

  describe '#retain_item!' do
    it '' # TODO: immediately
  end

  describe '#cancel_retain!' do
    it '' # TODO: immediately
  end

  describe '#inter_library_loaned?' do
    it '' # TODO
  end

  describe '#creator' do
    it '' # TODO
  end

  describe '#contributor' do
    it '' # TODO
  end  

  describe '#publisher' do
    it '' # TODO
  end

  describe '#library' do
    it '' # TODO
  end

  describe '#shelf_name' do
    it '' # TODO
  end

  describe '#hold?' do
    it '' # TODO
  end

  describe '#lending_rule' do
    it '' # TODO
  end

  describe '#owned' do
    it '' # TODO
  end

  describe '#library_url' do
    it '' # TODO
  end

  describe '#manifestation_url' do
    it '' # TODO
  end

  describe '#deletable?' do
    it '' # TODO: immediately
  end

  describe '#not_for_loan?' do
    it '' # TODO
  end

  describe '#check_remove_item' do
    it '' # TODO: immediately
  end

  describe '#check_price' do
    it '' # TODO: immediately
  end

  describe '#is_original?' do
    it '' # TODO: immediately
  end

  describe '#set_retention_period' do
    it '' # TODO
  end

  describe '#set_rank' do
    it '' # TODO: immediately
  end

  describe '#item_bind' do
    it '' # TODO: immediately
  end

  describe '#excel_worksheet_value' do
    it '' # TODO: immediately
  end

  describe '.export_removing_list' do
    it '' # TODO
  end

  describe '.export_item_register' do
    it '' # TODO
  end

  describe '.export_audio_list' do
    it '' # TODO
  end

  describe '.patrons_list' do
    it '' # TODO
  end

  describe '.make_item_register_tsv' do
    it '' # TODO
  end

  describe '.make_audio_list_tsv' do
    it '' # TODO
  end

  describe '.make_item_register_pdf' do
    it '' # TODO
  end

  describe '.make_audio_list_pdf' do
    it '' # TODO
  end

  describe '.make_export_item_list_pdf' do
    it '' # TODO
  end

  describe '.make_export_item_list_tsv' do
    it '' # TODO
  end

  describe '.make_export_new_item_list_pdf' do
    it '' # TODO
  end

  describe '.make_export_new_item_list_tsv' do
    it '' # TODO
  end

  describe '.make_export_removed_list_pdf' do
    it '' # TODO
  end

  describe '.make_export_new_book_list_pdf' do
    it '' # TODO
  end

  describe '.make_export_new_book_list_tsv' do
    it '' # TODO
  end

  describe '.make_export_series_statements_latest_list_pdf' do
    it '' # TODO
  end

  describe '.make_export_series_statements_latest_list_tsv' do
    it '' # TODO
  end

  describe '.make_export_series_statements_list_tsv' do
    it '' # TODO
  end

  describe '.make_export_item_list_job' do
    it '' # TODO
  end

  describe '.make_export_register_job' do
    it '' # TODO
  end

#TODO 以下元のテスト
  it "should be rent" do
    items(:item_00001).rent?.should be_true
  end

  it "should not be rent" do
    items(:item_00010).rent?.should be_false
  end

  it "should be checked out" do
    items(:item_00010).checkout!(users(:admin)).should be_true
    items(:item_00010).circulation_status.name.should eq 'On Loan'
  end

  it "should be checked in" do
    items(:item_00001).checkin!.should be_true
    items(:item_00001).circulation_status.name.should eq 'Available On Shelf'
  end

  it "should be retained" do
    old_count = MessageRequest.count
    items(:item_00022).retain(users(:librarian1)).should be_true
    MessageRequest.count.should eq old_count + 1
  end

  it "should not be checked out when it is clamed" do
    items(:item_00012).available_for_checkout?.should be_false
  end

  it "should have library_url" do
    items(:item_00001).library_url.should eq "#{LibraryGroup.site_config.url}libraries/web"
  end

  it "should not set next reserve when next reservation is blank" do
    items(:item_00028).set_next_reservation.should be_false
  end

  it "should set retained when receipt library of next reservation equal library of item" do
    items(:item_00027).set_next_reservation
    reserves(:reserve_00021).state.should eq 'retained'
  end

  it "should set in_process when receipt library of next reservation not equal library of item" do
    items(:item_00029).set_next_reservation
    reserves(:reserve_00024).state.should eq 'in_process'
  end

  it "should revert requested when item that is not retained  was check out" do
    items(:item_00029).checkout!(users(:admin)).should be_true
    reserves(:reserve_00023).state.should eq 'requested'
  end
end

=begin
describe GenerateItemListJob do
  fixtures :all

  describe '#initialize' do
    it '' #TODO
  end

  describe '#perform' do
    it '' #TODO
  end
end
=end

# == Schema Information
#
# Table name: items
#
#  id                          :integer         not null, primary key
#  call_number                 :string(255)
#  item_identifier             :string(255)
#  circulation_status_id       :integer         not null
#  checkout_type_id            :integer         default(1), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  shelf_id                    :integer         default(1), not null
#  include_supplements         :boolean         default(FALSE), not null
#  checkouts_count             :integer         default(0), not null
#  owns_count                  :integer         default(0), not null
#  resource_has_subjects_count :integer         default(0), not null
#  note                        :text
#  url                         :string(255)
#  price                       :integer
#  lock_version                :integer         default(0), not null
#  required_role_id            :integer         default(1), not null
#  state                       :string(255)
#  required_score              :integer         default(0), not null
#  acquired_at                 :datetime
#  bookstore_id                :integer
#

