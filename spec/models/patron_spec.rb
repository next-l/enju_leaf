# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Patron do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  describe "バリデーションテスト: " do
    before(:each) do
      @patron = patrons(:patron_00003)
    end

    it "入力値が全て正しいとき、エラーは発生しないこと" do
      @patron.should be_valid
    end
    # validates_presence_of :language, :patron_type, :country
    # validates_associated :language, :patron_type, :country
    it "language が不正のとき、エラーが発生すること" do
      @patron.language = nil
      expect(@patron).to have(2).errors_on(:language)
    end 
    it "patron_type が不正のとき、エラーが発生すること" do
      @patron.patron_type = nil
      expect(@patron).to have(2).errors_on(:patron_type)
    end
    it "country が不正のとき、エラーが発生すること" do
      @patron.country = nil
      expect(@patron).to have(2).errors_on(:country)
    end
    # validates :full_name, :presence => true, :length => {:maximum => 255}
    it "full_name が255字より大きとき、エラーが発生すること" do
      full_name = "a" * 256
      @patron.full_name = full_name
      @patron.should_not be_valid
    end
    #validates :user_id, :uniqueness => true, :allow_nil => true
    it "user_id がユニークでないとき、エラーが発生すること" do
      @patron.user = users(:admin) 
      @patron.should_not be_valid
    end
    # validates :birth_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
    it "birth_date のフォーマットが不正なとき、エラーが発生すること" do
      # case1 年、月、日のみ
      # case1_1. YYYY       => OK
      @patron.birth_date = '2000'
      @patron.should be_valid 
      # case1_2. MM        => OK
      @patron.birth_date = '01'
      @patron.should be_valid 
      # case1_3. D        => OK
      @patron.birth_date = '1'
      @patron.should be_valid 
      # case2 年月
      # case2_1. YYYY-MM    => OK
      @patron.birth_date = '2000-01'
      @patron.should be_valid
      # case2_2. YYYY-M     => OK
      @patron.birth_date = '2000-1'
      @patron.should be_valid
      # case2_3. YYYYMM     => OK
      @patron.birth_date = '200001'
      @patron.should be_valid 
      # case2_4. YYYYM      => OK
      @patron.birth_date = '20001'
      @patron.should be_valid 
      # case3 年月日
      # case3_1. YYYY-MM-DD => OK
      @patron.birth_date = '2000-01-01'
      @patron.should be_valid
      # case3_2. YYYY-MM-D  => OK
      @patron.birth_date = '2000-01-1'
      @patron.should be_valid
      # case3_3. YYYYMMDD   => OK
      @patron.birth_date = '20000101'
      @patron.should be_valid 
      # case3_4. YYYYMMD    => OK
      @patron.birth_date = '2000011'
      @patron.should be_valid 
      # case3_5. YYYY-MMDD  => NG
      @patron.birth_date = '2000-0101'
      @patron.should_not be_valid 
      # case3_6. YYYY-MM-DDD=> NG
      @patron.birth_date = '2000-01-011'
      @patron.should_not be_valid 
      # case4 他
      # case4_1. STRING     => NG
      @patron.birth_date = '平成元年'
      @patron.should_not be_valid 
      # case4_2. /          => NG
      @patron.birth_date = '2000/01/01'
      @patron.should_not be_valid 
      # case4_3. .          => NG
      @patron.birth_date = '2000.01.01'
      @patron.should_not be_valid 
    end
    # validates :death_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
    it "death_date のフォーマットが不正なとき、エラーが発生すること" do
      @patron.birth_date = '1900'
      # case1 年、月、日のみ
      # case1_1. YYYY       => OK
      @patron.death_date = '2000'
      @patron.should be_valid 
      # case1_2. MM        => OK
      @patron.death_date = '01'
      @patron.should be_valid 
      # case1_3. D        => OK
      @patron.death_date = '1'
      @patron.should be_valid 
      # case2 年月
      # case2_1. YYYY-MM    => OK
      @patron.death_date = '2000-01'
      @patron.should be_valid
      # case2_2. YYYY-M     => OK
      @patron.death_date = '2000-1'
      @patron.should be_valid
      # case2_3. YYYYMM     => OK
      @patron.death_date = '200001'
      @patron.should be_valid 
      # case2_4. YYYYM      => OK
      @patron.death_date = '20001'
      @patron.should be_valid 
      # case3 年月日
      # case3_1. YYYY-MM-DD => OK
      @patron.death_date = '2000-01-01'
      @patron.should be_valid
      # case3_2. YYYY-MM-D  => OK
      @patron.death_date = '2000-01-1'
      @patron.should be_valid
      # case3_3. YYYYMMDD   => OK
      @patron.death_date = '20000101'
      @patron.should be_valid 
      # case3_4. YYYYMMD    => OK
      @patron.death_date = '2000011'
      @patron.should be_valid 
      # case3_5. YYYY-MMDD  => NG
      @patron.death_date = '2000-0101'
      @patron.should_not be_valid 
      # case3_6. YYYY-MM-DDD=> NG
      @patron.death_date = '2000-01-011'
      @patron.should_not be_valid 
      # case4 他
      # case4_1. STRING     => NG
      @patron.death_date = '平成元年'
      @patron.should_not be_valid 
      # case4_2. /          => NG
      @patron.death_date = '2000/01/01'
      @patron.should_not be_valid 
      # case4_3. .          => NG
      @patron.death_date = '2000.01.01'
      @patron.should_not be_valid 
    end
    # validates :email, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}, :allow_blank => true
    it "email のフォーマットが不正なとき、エラーが発生すること" do
      # case1. blank
      @patron.email = ''
      @patron.should be_valid
      # case2. right
      @patron.email = 'enju@example.com'
      @patron.should be_valid
      # case3. wrong
      @patron.email = 'enjuexample.com'
      @patron.should_not be_valid
    end
    # validate :check_birth_date
    it "生年月日が没年月日より後のとき、エラーが発生すること" do
      # case1. right
      @patron.birth_date = '2000-01-01'
      @patron.death_date = '2000-01-01'
      @patron.should be_valid
      # case2. wrong
      @patron.birth_date = '2000-01-02'
      @patron.death_date = '2000-01-01'
      @patron.should_not be_valid
    end 
    # validate :check_duplicate_user
    it "ユーザ情報の重複チェックを行うか" do
      duplicate_patron     = Patron.new(:full_name => 'Kosuke Tanabe', :birth_date => '2000-01-01')
      not_duplicate_patron = Patron.new(:full_name => 'Kosuke Tanabe', :birth_date => '2000-01-02')

      # case1. duplicate
      system_configuration = SystemConfiguration.find_by_keyname('patron.check_duplicate_user')
      system_configuration.v = true
      system_configuration.save 
      duplicate_patron.should_not be_valid
      not_duplicate_patron.should be_valid
      # case2. it do not check duplication
      system_configuration = SystemConfiguration.find_by_keyname('patron.check_duplicate_user')
      system_configuration.v = false
      system_configuration.save 
      duplicate_patron.should be_valid
      not_duplicate_patron.should be_valid
    end
  end 
 
  # 以後、メソッドに関するテスト :TODO
  it "should full_name without space" do
    patron = Patron.new(:full_name => 'enju taro') 
    patron.full_name_without_space.should eq 'enjutaro'
  end

  it "should set role and name" do
  end

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

