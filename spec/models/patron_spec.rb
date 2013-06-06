# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Patron do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should set a default required_role to Guest" do
    patron = FactoryGirl.create(:patron)
    patron.required_role.should eq Role.find_by_name('Guest')
  end

  it "should set birth_date" do
    patron = FactoryGirl.create(:patron, :birth_date => '2000')
    patron.date_of_birth.should eq Time.zone.parse('2000-01-01')
  end

  it "should set death_date" do
    patron = FactoryGirl.create(:patron, :death_date => '2000')
    patron.date_of_death.should eq Time.zone.parse('2000-01-01')
  end

  it "should not set death_date earlier than birth_date" do
    patron = FactoryGirl.create(:patron, :birth_date => '2010', :death_date => '2000')
    patron.should_not be_valid
  end

  it "should be creator" do
    patrons(:patron_00001).creator?(manifestations(:manifestation_00001)).should be_true
  end

  it "should not be creator" do
    patrons(:patron_00010).creator?(manifestations(:manifestation_00001)).should be_false
  end

  it "should be publisher" do
    patrons(:patron_00001).publisher?(manifestations(:manifestation_00001)).should be_true
  end

  it "should not be publisher" do
    patrons(:patron_00010).publisher?(manifestations(:manifestation_00001)).should be_false
  end

  it "should get or create patron" do
    creator = "著者1;著者2;出版社テスト;試験用会社"
    creator_transcription = "ちょしゃいち;ちょしゃに;;しけんようかいしゃ"
    list = Patron.add_patrons(creator, creator_transcription)
    list[0].full_name.should eq "著者1"
    list[0].full_name_transcription.should eq"ちょしゃいち"
    list[1].full_name.should eq "著者2"
    list[1].full_name_transcription.should eq "ちょしゃに"
    list[2].id.should eq 102
    list[3].id.should eq 104
    list[3].full_name.should eq "試験用会社"
    list[3].full_name_transcription.should eq "しけんようかいしゃ"
  end
end

# == Schema Information
#
# Table name: patrons
#
#  id                                  :integer         not null, primary key
#  user_id                             :integer
#  last_name                           :string(255)
#  middle_name                         :string(255)
#  first_name                          :string(255)
#  last_name_transcription             :string(255)
#  middle_name_transcription           :string(255)
#  first_name_transcription            :string(255)
#  corporate_name                      :string(255)
#  corporate_name_transcription        :string(255)
#  full_name                           :string(255)
#  full_name_transcription             :text
#  full_name_alternative               :text
#  created_at                          :datetime
#  updated_at                          :datetime
#  deleted_at                          :datetime
#  zip_code_1                          :string(255)
#  zip_code_2                          :string(255)
#  address_1                           :text
#  address_2                           :text
#  address_1_note                      :text
#  address_2_note                      :text
#  telephone_number_1                  :string(255)
#  telephone_number_2                  :string(255)
#  fax_number_1                        :string(255)
#  fax_number_2                        :string(255)
#  other_designation                   :text
#  place                               :text
#  street                              :text
#  locality                            :text
#  region                              :text
#  date_of_birth                       :datetime
#  date_of_death                       :datetime
#  language_id                         :integer         default(1), not null
#  country_id                          :integer         default(1), not null
#  patron_type_id                      :integer         default(1), not null
#  lock_version                        :integer         default(0), not null
#  note                                :text
#  creates_count                       :integer         default(0), not null
#  realizes_count                      :integer         default(0), not null
#  produces_count                      :integer         default(0), not null
#  owns_count                          :integer         default(0), not null
#  required_role_id                    :integer         default(1), not null
#  required_score                      :integer         default(0), not null
#  state                               :string(255)
#  email                               :text
#  url                                 :text
#  full_name_alternative_transcription :text
#  title                               :string(255)
#  birth_date                          :string(255)
#  death_date                          :string(255)
#  address_1_key                       :binary
#  address_1_iv                        :binary
#  address_2_key                       :binary
#  address_2_iv                        :binary
#  telephone_number_key                :binary
#  telephone_number_iv                 :binary
#

