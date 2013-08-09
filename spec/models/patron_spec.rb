# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Patron do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  describe "バリデーションテスト: " do
    before(:each) do
      @patron = patrons(:patron_00003)
    end

    context "入力値が全て正しいとき" do
      it "エラーは発生しないこと" do
        @patron.should be_valid
      end
    end
    # validates_presence_of :language, :patron_type, :country
    # validates_associated :language, :patron_type, :country
    describe "値が nil > " do
      it "language にエラーが発生すること" do
        @patron.language = nil
        expect(@patron).to have(2).errors_on(:language)
      end 
      it "patron_type にエラーが発生すること" do
        @patron.patron_type = nil
        expect(@patron).to have(2).errors_on(:patron_type)
      end
      it "country にエラーが発生すること" do
        @patron.country = nil
        expect(@patron).to have(2).errors_on(:country)
      end
    end
    # validates :full_name, :presence => true, :length => {:maximum => 255}
    describe "文字数 > " do
      describe "full_name > " do
        context "255字以下のとき" do
          it "エラーが発生しないこと" do
            full_name = "a" * 255
            @patron.stub(:full_name).and_return(full_name)
            @patron.should be_valid
          end
        end
        context "255字より大きいとき" do
          it "エラーが発生すること" do
            full_name = "a" * 256
            @patron.stub(:full_name).and_return(full_name)
            @patron.should_not be_valid
          end
        end
      end
    end
    #validates :user_id, :uniqueness => true, :allow_nil => true
    describe "ユニーク > " do
      describe "user_id > " do
        context "ユニークなとき" do
          it "エラーが発生しないこと" do
            @patron.stub(:user).and_return(FactoryGirl.create(:user))
            @patron.should be_valid
          end
        end
        context "ユニークでないとき" do
          it "エラーが発生すること" do
            @patron.stub(:user_id).and_return(users(:admin).id)
            @patron.should_not be_valid
          end
        end
      end
    end
    # validates :birth_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
    describe "birth_date の日付フォーマット > " do
      before(:each) do
        @patron.stub(:date_of_death).and_return(nil)
      end
      describe "\d > " do
        it "エラーが発生しないこと: YYYY" do
          @patron.stub(:birth_date).and_return('2000')
          @patron.should be_valid
        end
        it "エラーが発生しないこと: MM" do
          @patron.stub(:birth_date).and_return('01')
          @patron.should be_valid 
        end
        it "エラーが発生しないこと: D" do
          @patron.stub(:birth_date).and_return('1')
          @patron.should be_valid 
        end
        it "エラーが発生しないこと: YYYYM" do
          @patron.stub(:birth_date).and_return('20001')
          @patron.should be_valid
        end
        it "エラーが発生しないこと: YYYYMM" do
          @patron.stub(:birth_date).and_return('200001')
          @patron.should be_valid
        end
        it "エラーが発生しないこと: YYYYMMD" do
          @patron.stub(:birth_date).and_return('2000011')
          @patron.should be_valid 
        end
        it "エラーが発生しないこと: YYYYMMDD" do
          @patron.stub(:birth_date).and_return('20000101')
          @patron.should be_valid 
        end
      end
      describe "\d-\d{0,2} > " do
        context "フォーマットが正しいとき > " do
          it "エラーが発生しないこと: YYYY-" do
            @patron.stub(:birth_date).and_return('2000-')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-M" do
            @patron.stub(:birth_date).and_return('2000-1')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-MM" do
            @patron.stub(:birth_date).and_return('2000-01')
            @patron.should be_valid
          end
        end
        context "フォーマットが不正なとき > " do
          it "エラーが発生すること: YYYY-MMDD" do
            @patron.stub(:birth_date).and_return('2000-0101')
            @patron.should_not be_valid 
          end
        end
      end
      describe "\d-\d{0,2}-\d{0,2} > " do
        context "フォーマットが正しいとき > " do
          it "エラーが発生しないこと: YYYY-MM-" do
            @patron.stub(:birth_date).and_return('2000-01-')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-MM-D" do
            @patron.stub(:birth_date).and_return('2000-01-1')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-MM-DD" do
            @patron.stub(:birth_date).and_return('2000-01-01')
            @patron.should be_valid
          end
        end
        context "フォーマットが不正なとき > " do
          it "エラーが発生すること: YYYY-MM-DDD" do
            @patron.stub(:birth_date).and_return('2000-01-011')
            @patron.should_not be_valid 
          end
        end
      end
      describe "other > " do
        context "フォーマットが不正なとき > " do
          it "エラーが発生すること: STRING" do
            @patron.stub(:birth_date).and_return('平成元年')
            @patron.should_not be_valid 
          end
          it "エラーが発生すること: / " do
            @patron.stub(:birth_date).and_return('2000/01/01')
            @patron.should_not be_valid 
          end
          it "エラーが発生すること: ." do
            @patron.stub(:birth_date).and_return('2000.01.01')
            @patron.should_not be_valid 
          end
        end
      end
    end
    # validates :death_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
    describe "death_date の日付フォーマット > " do
      before(:each) do
        @patron.stub(:date_of_birth).and_return(nil)
      end
      describe "\d > " do
        it "エラーが発生しないこと: YYYY" do
          @patron.stub(:death_date).and_return('2000')
          @patron.should be_valid
        end
        it "エラーが発生しないこと: MM" do
          @patron.stub(:death_date).and_return('01')
          @patron.should be_valid 
        end
        it "エラーが発生しないこと: D" do
          @patron.stub(:death_date).and_return('1')
          @patron.should be_valid 
        end
        it "エラーが発生しないこと: YYYYM" do
          @patron.stub(:death_date).and_return('20001')
          @patron.should be_valid
        end
        it "エラーが発生しないこと: YYYYMM" do
          @patron.stub(:death_date).and_return('200001')
          @patron.should be_valid
        end
        it "エラーが発生しないこと: YYYYMMD" do
          @patron.stub(:death_date).and_return('2000011')
          @patron.should be_valid 
        end
        it "エラーが発生しないこと: YYYYMMDD" do
          @patron.stub(:death_date).and_return('20000101')
          @patron.should be_valid 
        end
      end
      describe "\d-\d{0,2} > " do
        context "フォーマットが正しいとき > " do
          it "エラーが発生しないこと: YYYY-" do
            @patron.stub(:death_date).and_return('2000-')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-M" do
            @patron.stub(:death_date).and_return('2000-1')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-MM" do
            @patron.stub(:death_date).and_return('2000-01')
            @patron.should be_valid
          end
        end
        context "フォーマットが不正なとき > " do
          it "エラーが発生すること: YYYY-MMDD" do
            @patron.stub(:death_date).and_return('2000-0101')
            @patron.should_not be_valid 
          end
        end
      end
      describe "\d-\d{0,2}-\d{0,2} > " do
        context "フォーマットが正しいとき > " do
          it "エラーが発生しないこと: YYYY-MM-" do
            @patron.stub(:death_date).and_return('2000-01-')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-MM-D" do
            @patron.stub(:death_date).and_return('2000-01-1')
            @patron.should be_valid
          end
          it "エラーが発生しないこと: YYYY-MM-DD" do
            @patron.stub(:death_date).and_return('2000-01-01')
            @patron.should be_valid
          end
        end
        context "フォーマットが不正なとき > " do
          it "エラーが発生すること: YYYY-MM-DDD" do
            @patron.stub(:death_date).and_return('2000-01-011')
            @patron.should_not be_valid 
          end
        end
      end
      describe "other > " do
        context "フォーマットが不正なとき > " do
          it "エラーが発生すること: STRING" do
            @patron.stub(:death_date).and_return('平成元年')
            @patron.should_not be_valid 
          end
          it "エラーが発生すること: / " do
            @patron.stub(:death_date).and_return('2000/01/01')
            @patron.should_not be_valid 
          end
          it "エラーが発生すること: ." do
            @patron.stub(:death_date).and_return('2000.01.01')
            @patron.should_not be_valid 
          end
        end
      end
    end
    # validates :email, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}, :allow_blank => true
    describe "emailのフォーマット > " do
      context "値が空のとき" do
        it "エラーが発生しないこと" do
          @patron.email = ''
          @patron.should be_valid
        end
      end
      context "フォーマットが正しいのとき" do
        it "エラーが発生しないこと" do
          @patron.stub(:email).and_return('enju@example.com')
          @patron.should be_valid
        end
      end
      context "フォーマットが不正のとき" do
        it "エラーが発生すること" do
          @patron.stub(:email).and_return('enjuexample.com')
          @patron.should_not be_valid
        end
      end
    end
    # validate :check_birth_date
    context "生年月日が没年月日より前のとき" do
      it "エラーが発生しないこと" do
        @patron.stub(:birth_date => '2000-01-02')
        @patron.stub(:death_date => '2000-01-01')
        @patron.should_not be_valid
      end
    end 
    context "生年月日が没年月日より後のとき" do
      it "エラーが発生すること" do
        @patron.stub(:birth_date => '2000-01-01')
        @patron.stub(:death_date => '2000-01-01')
        @patron.should be_valid
      end
    end
    # validate :check_duplicate_user
    it "ユーザ情報の重複チェックを行うか" do
      duplicate_patron     = Patron.new(
        :full_name => @patron.full_name, 
        :birth_date => @patron.birth_date,
        :telephone_number_1 => @patron.telephone_number_1
      )
      not_duplicate_patron = Patron.new(
        :full_name => @patron.full_name, 
        :birth_date => @patron.birth_date,
        :telephone_number_1 => "tes-#{@patron.telephone_number_1}"
      )
      # case1. duplicate
      system_configuration = SystemConfiguration.find_by_keyname('patron.check_duplicate_user')
      system_configuration.v = "true"
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
 
  # 以後、メソッドに関するテスト 
  it "should full_name without space" do
    patron = Patron.new(:full_name => 'enju taro') 
    patron.full_name_without_space.should eq 'enjutaro'
  end

  it "should set a default required_role to Guest" do
    patron = FactoryGirl.create(:patron)
    patron.required_role.should eq Role.find_by_name('Guest')
  end 

  describe "set a role:" do
    it "should set a required_role to Librarian when required_role is nil" do
      patron = FactoryGirl.create(:patron).stub(:required_role => nil)
      set_role_and_name.should eq Role.find_by_name('Librarian')
    end
    it "should set a required_role to Guest" do
      patron = FactoryGirl.create(:patron).stub(:required_role => Role.find_by_name('Guest'))
      set_role_and_name.should eq Role.find_by_name('Guest')
    end
    it "should set a required_role to Librarian" do
      patron = FactoryGirl.create(:patron).stub(:required_role => Role.find_by_name('Librarian'))
      set_role_and_name.should eq Role.find_by_name('Librarian')
    end
    it "should set a required_role to Administrator" do
      patron = FactoryGirl.create(:patron).stub(:required_role => Role.find_by_name('Administrator'))
      set_role_and_name.should eq Role.find_by_name('Administrator')
    end
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

