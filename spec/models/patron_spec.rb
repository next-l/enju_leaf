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
    describe "ユーザ情報の重複チェック > " do
      before(:each) do
        @duplicate_patron     = Patron.new(
          :full_name => @patron.full_name, 
          :full_name_transcription => @patron.full_name_transcription,
          :birth_date => @patron.birth_date,
          :telephone_number_1 => @patron.telephone_number_1
        )
      end
      context "重複チェック行う > " do
        before(:each) do
          system_configuration = SystemConfiguration.find_by_keyname('patron.check_duplicate_user')
          system_configuration.v = "true"
          system_configuration.save
          Rails.cache.clear 
        end
        context "full_name_transcription, birth_date, telephone_number_1 が全て同一のユーザを登録しようとするとき" do
          it "エラーが発生すること" do
            @duplicate_patron.should_not be_valid
          end
        end
        
        context "birth_date, telephone_number_1 が同一で full_name_transcription が異なるユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.stub(:full_name_transcription => nil)
            @duplicate_patron.should be_valid
          end
        end
        context "full_name_transcription, telephone_number_1 が同一で birth_date が異なるユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.stub(:birth_date => nil)
            @duplicate_patron.should be_valid
          end
        end
        context "full_name_transcription, birth_date が同一で telephone_number_1 が異なるユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.stub(:telephone_number_1 => nil)
            @duplicate_patron.should be_valid
          end
        end
      end
      context "重複チェック行わない > " do
        before(:each) do
          system_configuration = SystemConfiguration.find_by_keyname('patron.check_duplicate_user')
          system_configuration.v = "false"
          system_configuration.save 
          Rails.cache.clear 
        end
        context "full_name_transcription, birth_date, telephone_number_1 が全て同一のユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.should be_valid
          end
        end
        context "birth_date, telephone_number_1 が同一で full_name_transcription が異なるユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.stub(:full_name_transcription => nil)
            @duplicate_patron.should be_valid
          end
        end
        context "full_name_transcription, telephone_number_1 が同一で birth_date が異なるユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.stub(:birth_date => nil)
            @duplicate_patron.should be_valid
          end
        end
        context "full_name_transcription, birth_date が同一で telephone_number_1 が異なるユーザを登録しようとするとき" do
          it "エラーが発生しないこと" do
            @duplicate_patron.stub(:telephone_number_1 => nil)
            @duplicate_patron.should be_valid
          end
        end
      end
    end
  end 

  # default set 
  it "should set a default required_role to Guest" do
    patron = FactoryGirl.create(:patron)
    patron.required_role.should eq Role.find_by_name('Guest')
  end 

  # before_validation
  context "set role > " do
    it "should set a required_role to Librarian when required_role is nil" do
      patron = FactoryGirl.create(:patron, :required_role => nil)
      patron.valid?
      patron.required_role.should eq Role.find_by_name('Librarian')
    end
    it "should set a required_role to Guest" do
      patron = FactoryGirl.create(:patron, :required_role => Role.find_by_name('Guest'))
      patron.valid?
      patron.required_role.should eq Role.find_by_name('Guest')
    end
    it "should set a required_role to Librarian" do
      patron = FactoryGirl.create(:patron, :required_role => Role.find_by_name('Librarian'))
      patron.valid?
      patron.required_role.should eq Role.find_by_name('Librarian')
    end
    it "should set a required_role to Administrator" do
      patron = FactoryGirl.create(:patron, :required_role => Role.find_by_name('Administrator'))
      patron.valid?
      patron.required_role.should eq Role.find_by_name('Administrator')
    end
  end

  context "set full_name > " do
    before(:each) do
      @patron = Patron.new(
        :full_name                 => 'フルネーム', 
        :full_name_transcription   => 'フルネーム（ヨミ）', 
        :last_name                 => '姓',
        :last_name_transcription   => '姓（ヨミ）', 
        :middle_name               => 'ミドルネーム',
        :middle_name_transcription => 'ミドルネーム（ヨミ）',
        :first_name                => '名',
        :first_name_transcription  => '名（ヨミ）'
      )
    end
    context "full_name が空でないとき" do
      it "full_name が設定されること" do
        @patron.set_full_name[0].should eq 'フルネーム' 
      end
    end 
    context "full_name_transcription が空でないとき" do
      it "full_name が設定されること" do
        @patron.set_full_name[1].should eq 'フルネーム（ヨミ）' 
      end
    end 
    context "システム設定で姓を先に表示するよう設定しており" do
      before(:each) do
        system_configuration = SystemConfiguration.find_by_keyname('family_name_first')
        system_configuration.v = "true"
        system_configuration.save 
        Rails.cache.clear 
      end
      context "full_name が空かつ" do
        before(:each) do
          @patron.full_name = nil
        end
        context "last_name, middle_name, first_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.set_full_name[0].should eq '姓 ミドルネーム 名'
          end
        end 
        context "first_name が空で last_name, middle_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.first_name = nil
            @patron.set_full_name[0].should eq '姓 ミドルネーム'
          end
        end 
        context "middle_name が空で last_name, first_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.middle_name = nil
            @patron.set_full_name[0].should eq '姓 名'
          end
        end 
        context "last_name が空で middle_name, first_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.last_name = nil
            @patron.set_full_name[0].should eq 'ミドルネーム 名'
          end
        end 
        context " middle_name, first_name が空で last_name が入力されているとき" do
          it "full_name に 'last_name' が登録されること" do
            @patron.first_name  = nil
            @patron.middle_name = nil
            @patron.set_full_name[0].should eq '姓'
          end
        end
        context " last_name, middle_name が空で first_name が入力されているとき" do
          it "full_name に 'first_name' が登録されること" do
            @patron.last_name   = nil
            @patron.middle_name = nil
            @patron.set_full_name[0].should eq '名'
          end
        end
        context " last_name, first_name が空で middle_name が入力されているとき" do
          it "full_name に 'middle_name' が登録されること" do
            @patron.last_name  = nil
            @patron.first_name = nil
            @patron.set_full_name[0].should eq 'ミドルネーム'
          end
        end
        context "first_name, middle_name, last_name が全て入力されていないとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.last_name   = nil
            @patron.middle_name = nil 
            @patron.first_name  = nil
            @patron.set_full_name[0].should eq ''
          end
        end 
      end
      context "full_name_transcription が空かつ" do
        before(:each) do
          @patron.full_name_transcription = nil
        end
        context "last_name_transcription, middle_name_transcription, first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.set_full_name[1].should eq '姓（ヨミ） ミドルネーム（ヨミ） 名（ヨミ）'
          end
        end 
        context "first_name_transcription が空で last_name_transcription, middle_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.first_name_transcription = nil
            @patron.set_full_name[1].should eq '姓（ヨミ） ミドルネーム（ヨミ）'
          end
        end 
        context "middle_name_transcription が空で last_name_transcription, first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.middle_name_transcription = nil
            @patron.set_full_name[1].should eq '姓（ヨミ） 名（ヨミ）'
          end
        end 
        context "last_name_transcription が空で middle_name_transcription, first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.last_name_transcription = nil
            @patron.set_full_name[1].should eq 'ミドルネーム（ヨミ） 名（ヨミ）'
          end
        end 
        context "middle_name_transcription, first_name_transcription が空で last_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription' が登録されること" do
            @patron.first_name_transcription  = nil
            @patron.middle_name_transcription = nil
            @patron.set_full_name[1].should eq '姓（ヨミ）'
          end
        end
        context "last_name_transcription, middle_name_transcription が空で first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'first_name_transcription' が登録されること" do
            @patron.last_name_transcription   = nil
            @patron.middle_name_transcription = nil
            @patron.set_full_name[1].should eq '名（ヨミ）'
          end
        end
        context " last_name_transcription, first_name_transcription が空で middle_name_transcription が入力されているとき" do
          it "full_name_transcription に 'middle_name_transcription' が登録されること" do
            @patron.last_name_transcription  = nil
            @patron.first_name_transcription = nil
            @patron.set_full_name[1].should eq 'ミドルネーム（ヨミ）'
          end
        end
      end
    end
    context "システム設定で姓を先に表示するよう設定しておらず" do
      before(:each) do
        system_configuration = SystemConfiguration.find_by_keyname('family_name_first')
        system_configuration.v = "false"
        system_configuration.save 
        Rails.cache.clear 
      end
      context "full_name が空かつ" do
        before(:each) do
          @patron.full_name = nil
        end
        context "last_name, middle_name, first_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.set_full_name[0].should eq '名 ミドルネーム 姓'
          end
        end 
        context "first_name が空で last_name, middle_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.first_name = nil
            @patron.set_full_name[0].should eq 'ミドルネーム 姓'
          end
        end 
        context "middle_name が空で last_name, first_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.middle_name = nil
            @patron.set_full_name[0].should eq '名 姓'
          end
        end 
        context "last_name が空で middle_name, first_name が入力されているとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.last_name = nil
            @patron.set_full_name[0].should eq '名 ミドルネーム'
          end
        end 
        context " middle_name, first_name が空で last_name が入力されているとき" do
          it "full_name に 'last_name' が登録されること" do
            @patron.first_name  = nil
            @patron.middle_name = nil
            @patron.set_full_name[0].should eq '姓'
          end
        end
        context " last_name, middle_name が空で first_name が入力されているとき" do
          it "full_name に 'first_name' が登録されること" do
            @patron.last_name   = nil
            @patron.middle_name = nil
            @patron.set_full_name[0].should eq '名'
          end
        end
        context " last_name, first_name が空で middle_name が入力されているとき" do
          it "full_name に 'middle_name' が登録されること" do
            @patron.last_name  = nil
            @patron.first_name = nil
            @patron.set_full_name[0].should eq 'ミドルネーム'
          end
        end
        context "first_name, middle_name, last_name が全て入力されていないとき" do
          it "full_name に 'last_name first_name' が登録されること" do
            @patron.last_name   = nil
            @patron.middle_name = nil 
            @patron.first_name  = nil
            @patron.set_full_name[0].should eq ''
          end
        end 
      end
      context "full_name_transcription が空かつ" do
        before(:each) do
          @patron.full_name_transcription = nil
        end
        context "last_name_transcription, middle_name_transcription, first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.set_full_name[1].should eq '名（ヨミ） ミドルネーム（ヨミ） 姓（ヨミ）'
          end
        end 
        context "first_name_transcription が空で last_name_transcription, middle_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.first_name_transcription = nil
            @patron.set_full_name[1].should eq 'ミドルネーム（ヨミ） 姓（ヨミ）'
          end
        end 
        context "middle_name_transcription が空で last_name_transcription, first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.middle_name_transcription = nil
            @patron.set_full_name[1].should eq '名（ヨミ） 姓（ヨミ）'
          end
        end 
        context "last_name_transcription が空で middle_name_transcription, first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription first_name_transcription' が登録されること" do
            @patron.last_name_transcription = nil
            @patron.set_full_name[1].should eq '名（ヨミ） ミドルネーム（ヨミ）'
          end
        end 
        context "middle_name_transcription, first_name_transcription が空で last_name_transcription が入力されているとき" do
          it "full_name_transcription に 'last_name_transcription' が登録されること" do
            @patron.first_name_transcription  = nil
            @patron.middle_name_transcription = nil
            @patron.set_full_name[1].should eq '姓（ヨミ）'
          end
        end
        context "last_name_transcription, middle_name_transcription が空で first_name_transcription が入力されているとき" do
          it "full_name_transcription に 'first_name_transcription' が登録されること" do
            @patron.last_name_transcription   = nil
            @patron.middle_name_transcription = nil
            @patron.set_full_name[1].should eq '名（ヨミ）'
          end
        end
        context " last_name_transcription, first_name_transcription が空で middle_name_transcription が入力されているとき" do
          it "full_name_transcription に 'middle_name_transcription' が登録されること" do
            @patron.last_name_transcription  = nil
            @patron.first_name_transcription = nil
            @patron.set_full_name[1].should eq 'ミドルネーム（ヨミ）'
          end
        end
      end
    end
  end

  context "set date_of_birth > " do
    it "should set date_of_birth: YYYY" do
      patron = FactoryGirl.create(:patron, :birth_date => '2000')
      patron.date_of_birth.should eq Time.zone.parse('2000-01-01')
    end
    it "should set date_of_birth: YYYY-MM" do
      patron = FactoryGirl.create(:patron, :birth_date => '2000-12')
      patron.date_of_birth.should eq Time.zone.parse('2000-12-01')
    end
    it "should set date_of_birth: YYYY-MM-DD" do
      patron = FactoryGirl.create(:patron, :birth_date => '2000-12-31')
      patron.date_of_birth.should eq Time.zone.parse('2000-12-31')
    end
    it "should not set date_of_birth: nil" do
      patron = FactoryGirl.create(:patron, :birth_date => nil)
      patron.date_of_birth.should eq nil
    end
  end

  context "set date_of_death > " do
    it "should set date_of_death" do
      patron = FactoryGirl.create(:patron, :death_date => '2000')
      patron.date_of_death.should eq Time.zone.parse('2000-01-01')
    end
    it "should set date_of_death: YYYY" do
      patron = FactoryGirl.create(:patron, :death_date => '2000')
      patron.date_of_death.should eq Time.zone.parse('2000-01-01')
    end
    it "should set date_of_death: YYYY-MM" do
      patron = FactoryGirl.create(:patron, :death_date => '2000-12')
      patron.date_of_death.should eq Time.zone.parse('2000-12-01')
    end
    it "should set date_of_death: YYYY-MM-DD" do
      patron = FactoryGirl.create(:patron, :death_date => '2000-12-31')
      patron.date_of_death.should eq Time.zone.parse('2000-12-31')
    end
    it "should not set date_of_death: nil" do
      patron = FactoryGirl.create(:patron, :death_date => nil)
      patron.date_of_death.should eq nil
    end
  end

  # other
  context "full_name has space > " do
    it "should full_name without space: enju taro" do
      patron = Patron.new(:full_name => 'enju taro') 
      patron.full_name_without_space.should eq 'enjutaro'
    end
    it "should full_name without space: enju mirait taro" do
      patron = Patron.new(:full_name => 'enju mirait taro') 
      patron.full_name_without_space.should eq 'enjumiraittaro'
    end
    it "should full_name without space: enju　taro" do
      patron = Patron.new(:full_name => 'enju　taro') 
      patron.full_name_without_space.should eq 'enju　taro'
    end
  end

  context "full_name_transcription has space > " do
    it "should full_name_transcription without space: enju taro" do
      patron = Patron.new(:full_name_transcription => 'enju taro')
      patron.full_name_transcription_without_space.should eq 'enjutaro'
    end
    it "should full_name_transcription without space: enju mirait taro" do
      patron = Patron.new(:full_name_transcription => 'enju mirait taro') 
      patron.full_name_transcription_without_space.should eq 'enjumiraittaro'
    end
    it "should full_name_transcription without space: enju　taro" do
      patron = Patron.new(:full_name_transcription => 'enju　taro') 
      patron.full_name_transcription_without_space.should eq 'enju　taro'
    end
  end

  context "full_name_alternative has space > " do
    it "should full_name_alternative without space" do
      patron = Patron.new(:full_name_alternative => 'enju taro')
      patron.full_name_alternative_without_space.should eq 'enjutaro'
    end
    it "should full_name_alternative without space: enju mirait taro" do
      patron = Patron.new(:full_name_alternative => 'enju mirait taro') 
      patron.full_name_alternative_without_space.should eq 'enjumiraittaro'
    end
    it "should full_name_alternative without space: enju　taro" do
      patron = Patron.new(:full_name_alternative => 'enju　taro') 
      patron.full_name_alternative_without_space.should eq 'enju　taro'
    end
  end

  it "get names" do
    patron = Patron.new(
      :full_name => 'えんじゅ 太郎 ',
      :full_name_transcription => 'えんじゅ たろう',
      :full_name_alternative => 'enju taro'
    )
    patron.name.should eq ['えんじゅ 太郎', 'えんじゅ たろう', 'enju taro']
  end

  describe "get date" do 
    before(:each) do
      @patron = patrons(:patron_00003)
      @date_of_birth = Time.zone.parse('2000-01-01')
      @date_of_death = Time.zone.parse('2100-01-01')
      @patron.date_of_birth = @date_of_birth
      @patron.date_of_death = @date_of_death
    end
    context "has date_of_birth and date_of_death" do
      it "return 'date_of_death - date_of_death'" do
        @patron.date.should eq "#{@date_of_birth} - #{@date_of_death}"
      end
    end
    context "has only date_of_birth" do
      it "return 'date_of_death -'" do
        date_of_birth = nil
        @patron.date_of_death = nil
        @patron.date.should eq "#{@date_of_birth} -"
      end
    end
    context "has only date_of_death" do
      it "return nil" do
        @patron.date_of_birth = nil
        @patron.date.should eq nil
      end
    end
    context "has not date_of_birth and date_of_death" do
      it "return nil" do
        @patron.date_of_birth = nil
        @patron.date_of_death = nil
        @patron.date.should eq nil
      end
    end
  end

#  TODO: 未使用メソッド。不要なら削除すること
#  229   def creator?(resource)
#  230     resource.creators.include?(self)
#  231   end
  it "should be creator" do
    patrons(:patron_00001).creator?(manifestations(:manifestation_00001)).should be_true
  end
  it "should not be creator" do
    patrons(:patron_00010).creator?(manifestations(:manifestation_00001)).should be_false
  end

#  TODO: 未使用メソッド。不要なら削除すること
#  233   def publisher?(resource)
#  234     resource.publishers.include?(self)
#  235   end
  it "should be publisher" do
    patrons(:patron_00001).publisher?(manifestations(:manifestation_00001)).should be_true
  end
  it "should not be publisher" do
    patrons(:patron_00010).publisher?(manifestations(:manifestation_00001)).should be_false
  end

#  TODO: 未使用メソッド。不要なら削除すること
#  237   def check_required_role(user)
#  238     return true if self.user.blank?
#  239     return true if self.user.required_role.name == 'Guest'
#  240     return true if user == self.user
#  241     return true if user.has_role?(self.user.required_role.name)
#  242     false
#  243   rescue NoMethodError
#  244     false
#  245   end
  context "has required_role " do 
    describe "is blank," do
      it "should return true" do
        patron = FactoryGirl.create(:patron)
        patron.check_required_role(patron).should eq true
      end
    end
    describe "is Guest," do
      it "should return true" do
        patron      = FactoryGirl.create(:patron)
        patron.user = FactoryGirl.create(:guest)
        patron.check_required_role(patron.user).should eq true
      end
    end
    describe "is self.user," do
      it "should return true" do
        patron      = FactoryGirl.create(:patron)
        patron.user =  FactoryGirl.create(:user)
        patron.check_required_role(patron.user).should eq true
      end
    end
    describe "is same role," do
      it "should return true" do
        user        = FactoryGirl.create(:user)
        patron      = FactoryGirl.create(:patron)
        patron.user = FactoryGirl.create(:user)
        patron.check_required_role(user).should eq true
      end
    end
    describe "is other," do
      it "should return false" do
        user        = FactoryGirl.create(:guest)
        patron      = FactoryGirl.create(:patron)
        patron.user = FactoryGirl.create(:user)
        patron.check_required_role(user).should eq false
      end
    end
    describe "no method," do
      it "should return exception error" do
        proc{ Patron.check_required_role(nil) }.should raise_error
      end
    end
  end

#  TODO: 未使用メソッド。不要なら削除すること
#  247   def created(work)
#  248     creates.where(:work_id => work.id).first
#  249   end
#  251   def realized(expression)
#  252     realizes.where(:expression_id => expression.id).first
#  253   end
#  255   def produced(manifestation)
#  256     produces.where(:manifestation_id => manifestation.id).first
#  257   end
#  259   def owned(item)
#  260     owns.where(:item_id => item.id)
#  261   end
#  262
  it "should created" do
    patrons(:patron_00001).created(creates(:create_00001)).should eq creates(:create_00001)
  end
  it "should realized" do
    patrons(:patron_00001).realized(realizes(:realize_00001)).should eq realizes(:realize_00001)
  end
  it "should produced" do
    patrons(:patron_00001).produced(manifestations(:manifestation_00001)).should eq produces(:produce_00001)
  end
  it "should owned" do
    patrons(:patron_00001).owned(items(:item_00001)).should eq [owns(:own_00001)]
  end

  context "add from array_list" do
    describe "nil > " do
      it "should return empty list" do
        patron_lists = nil
        Patron.import_patrons(patron_lists).should eq []
      end
    end
    describe "blank > " do
      it "should return empty list" do
        patron_lists = []
        Patron.import_patrons(patron_lists).should eq []
      end
    end
    describe "blank attribute > " do
      it "should return empty list" do
        patron_lists = [{ full_name: '', full_name_transcription: '' }]
        Patron.import_patrons(patron_lists).should eq []
      end
      it "should return empty list" do
        patron_lists = [{ full_name: '', full_name_transcription: 'test' }]
        Patron.import_patrons(patron_lists).should eq []
      end
    end
    describe "duplication > " do
      it "should compact list" do
        patron_lists = [patrons(:patron_00001), patrons(:patron_00001)]
        Patron.import_patrons(patron_lists).should eq [patrons(:patron_00001)]
      end
    end
    describe "add exist patrons > " do
      it "should not exist new patron" do
        patron_lists = [patrons(:patron_00001), patrons(:patron_00002), patrons(:patron_00003)]
        Patron.import_patrons(patron_lists).should eq [patrons(:patron_00001), patrons(:patron_00002), patrons(:patron_00003)]
      end
    end
    describe "add new patrons > " do
      before(:each) do
        @time = Time.now
        @patron_lists = [
          { full_name: "p_#{@time}_1", full_name_transcription: "p_#{@time}_yomi_1" },
          { full_name: "p_#{@time}_2", full_name_transcription: "p_#{@time}_yomi_2" },
          { full_name: "p_#{@time}_3", full_name_transcription: "p_#{@time}_yomi_3" },
        ]
      end
      it "should create new patrons" do
        Patron.find_by_full_name(@patron_lists[0][:full_name]).should be_nil
        Patron.find_by_full_name(@patron_lists[1][:full_name]).should be_nil
        Patron.find_by_full_name(@patron_lists[2][:full_name]).should be_nil
        list = Patron.import_patrons(@patron_lists)
        p1 = Patron.find_by_full_name(@patron_lists[0][:full_name])
        p2 = Patron.find_by_full_name(@patron_lists[1][:full_name])
        p3 = Patron.find_by_full_name(@patron_lists[2][:full_name])
        p1.should_not be_nil
        p2.should_not be_nil
        p3.should_not be_nil
        list.should eq [p1, p2, p3]
      end
      describe "detail" do
        it "should set full_name" do
          list = Patron.import_patrons(@patron_lists)
          list[0][:full_name].should eq @patron_lists[0][:full_name]
          list[1][:full_name].should eq @patron_lists[1][:full_name]
          list[2][:full_name].should eq @patron_lists[2][:full_name]
        end
        it "should set full_name_transcription" do
          list = Patron.import_patrons(@patron_lists)
          list[0][:full_name_transcription].should eq @patron_lists[0][:full_name_transcription]
          list[1][:full_name_transcription].should eq @patron_lists[1][:full_name_transcription]
          list[2][:full_name_transcription].should eq @patron_lists[2][:full_name_transcription]
        end
        it "should set language_id is 1" do
          list = Patron.import_patrons(@patron_lists)
          list[0][:language_id].should eq 1
          list[1][:language_id].should eq 1
          list[2][:language_id].should eq 1
        end
        it "should set Guest's role" do
          list = Patron.import_patrons(@patron_lists)
          list[0][:required_role_id].should eq Role.find_by_name('Guest').id
          list[1][:required_role_id].should eq Role.find_by_name('Guest').id
          list[2][:required_role_id].should eq Role.find_by_name('Guest').id
        end
        it "set exclude_state" do
          system_configuration = SystemConfiguration.find_by_keyname('exclude_patrons')
          system_configuration.v = "#{system_configuration.v}, p_#{@time}_3"
          system_configuration.save
          Rails.cache.clear
          @patron_lists << { full_name: " 　p_#{@time}_3 　", full_name_transcription: " 　p_#{@time}_yomi_3 　" }    
          list = Patron.import_patrons(@patron_lists)
          list[0][:exclude_state].should eq 0
          list[3][:exclude_state].should eq 1
        end
        it "should exstrip with full size_space" do
          @patron_lists << { full_name: " 　p_#{@time}_3 　", full_name_transcription: " 　p_#{@time}_yomi_3 　" } 
          list = Patron.import_patrons(@patron_lists)
          list[3][:full_name].should eq "p_#{@time}_3"
          list[3][:full_name_transcription].should eq "p_#{@time}_yomi_3"
        end
      end
    end
  end

  context "add from string" do
    describe "nil > " do
      it "should return empty list" do
        Patron.add_patrons(nil).should eq []
        Patron.add_patrons(nil, nil).should eq []
      end
    end
    describe "blank > " do
      context "has not transcription" do
        it "should return empty list" do
          Patron.add_patrons('').should eq []
        end
      end
      context "has transcription" do
        it "should return empty list" do
          Patron.add_patrons('', nil).should eq []
          Patron.add_patrons('', '').should eq []
        end
      end
    end
    describe "blank attribute > " do
      context "has not transcription" do
        it "should return empty list" do
          patron_names1 = '; ; ;'
          patron_names2 = '；；；'
          Patron.add_patrons(patron_names1).should eq []
          Patron.add_patrons(patron_names2).should eq []
        end
      end
      context "has transcription" do
        it "should return empty list" do
          patron_names1 = '; ; ;'
          patron_names2 = '；；；'
          Patron.add_patrons(patron_names1, patron_names1).should eq []
          Patron.add_patrons(patron_names2, patron_names2).should eq []
          Patron.add_patrons(patron_names1, 'test').should eq []
          Patron.add_patrons(patron_names2, 'test').should eq []
        end
      end
    end
    describe "duplication > " do
      before(:each) do
        @patron = patrons(:patron_00003)
        @patron_names            = "#{@patron.full_name};#{@patron.full_name}"
        @patron_names_with_space = "#{@patron.full_name}; #{@patron.full_name}"
      end
      context "has not transcriptions" do
        it "should compact list" do
          Patron.add_patrons(@patron_names).should eq [@patron]
        end
        it "should compact lis: has spacet" do
          Patron.add_patrons(@patron_names_with_space).should eq [@patron]
        end
      end
      context "has transactions" do
        it "should return a patron" do
          patron_transcriptions = "#{@patron.full_name_transcription};#{@patron.full_name_transcription}"
          list = Patron.add_patrons(@patron_names, patron_transcriptions)
          list.should eq [@patron]
          list[0][:full_name].should eq @patron.full_name
          list[0][:full_name_transcription].should eq @patron.full_name_transcription
        end
        it "should return a patron that has transcription" do
          patron_transcriptions = "#{@patron.full_name_transcription}"
          list = Patron.add_patrons(@patron_names, patron_transcriptions)
          list.should eq [@patron]
          list[0][:full_name].should eq @patron.full_name
          list[0][:full_name_transcription].should eq @patron.full_name_transcription
        end
        it "should return a patron that has transcription that first of patron_transcriptions list" do
          patron_transcriptions = "#{@patron.full_name_transcription};#{@patron.full_name_transcription}_test"
          list = Patron.add_patrons(@patron_names, patron_transcriptions)
          list.should eq [@patron]
          list[0][:full_name].should eq @patron.full_name
          list[0][:full_name_transcription].should eq @patron.full_name_transcription
        end
        it "should return a patron" do
          patron_transcriptions = ";"
          list = Patron.add_patrons(@patron_names, patron_transcriptions)
          list.should eq [@patron]
          list[0][:full_name].should eq @patron.full_name
          list[0][:full_name_transcription].should eq ""
        end
        it "should return two parsons" do
          @patron2 = patrons(:patron_00006)
          @patron_names = "#{@patron_names};#{@patron2.full_name}"
          patron_transcriptions = "#{@patron.full_name_transcription};#{@patron.full_name_transcription}_1;#{@patron.full_name_transcription}_2"
          list = Patron.add_patrons(@patron_names, patron_transcriptions)
          list.should eq [@patron, @patron2]
          list[0][:full_name].should eq @patron.full_name
          list[0][:full_name_transcription].should eq @patron.full_name_transcription
          list[1][:full_name].should eq @patron2.full_name
          list[1][:full_name_transcription].should eq "#{@patron.full_name_transcription}_2"
        end
      end
    end
    context "size of names is not equal size of name transcriptions > " do
      describe "edit exist patrons > " do
        before(:each) do
          @patron1 = patrons(:patron_00006)
          @patron2 = patrons(:patron_00007)
          @patron3 = patrons(:patron_00008)
          @patron_names = "#{@patron1.full_name};#{@patron2.full_name};#{@patron3.full_name}"
        end
        describe "blank > "do
          it "should not set transcriptions" do
	    patron_transcriptions = ""
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq @patron2.full_name_transcription
            list[2][:full_name_transcription].should eq @patron3.full_name_transcription
          end
          it "should not set transcriptions" do
	    patron_transcriptions = " "
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq @patron2.full_name_transcription
            list[2][:full_name_transcription].should eq @patron3.full_name_transcription
          end
          it "should not set transcriptions" do
	    patron_transcriptions = ";"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq @patron3.full_name_transcription
          end
          it "should not set transcriptions" do
	    patron_transcriptions = " ; "
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq @patron3.full_name_transcription
          end
          it "should not set transcriptions" do
	    patron_transcriptions = ";;"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should not set transcriptions" do
	    patron_transcriptions = " ; ; "
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
        end
        describe "word > "do
          it "should set a first transcription" do
	    patron_transcriptions = "test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq "test"
            list[1][:full_name_transcription].should eq @patron2.full_name_transcription
            list[2][:full_name_transcription].should eq @patron3.full_name_transcription
          end
          it "should set a second transcription" do
	    patron_transcriptions = ";test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq "test"
            list[2][:full_name_transcription].should eq @patron3.full_name_transcription
          end
          it "should set a third transcription" do
	    patron_transcriptions = ";;test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq "test"
          end
          it "should not set transcriptions" do
	    patron_transcriptions = ";;;test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should set all transcriptions" do
	    patron_transcriptions = "test;test;test;test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1.full_name
            list[1][:full_name].should eq @patron2.full_name
            list[2][:full_name].should eq @patron3.full_name
            list[0][:full_name_transcription].should eq "test"
            list[1][:full_name_transcription].should eq "test"
            list[2][:full_name_transcription].should eq "test"
          end
        end
      end
      describe "edit new patrons > " do
        before(:each) do
          @time = Time.now
          @patron1 = { full_name: "p_#{@time}_1" }
          @patron2 = { full_name: "p_#{@time}_2" }
          @patron3 = { full_name: "p_#{@time}_3" }
          @patron_names = "#{@patron1[:full_name]};#{@patron2[:full_name]};#{@patron3[:full_name]}"
        end
        describe "blank > "do
          it "should not set transcriptions" do
	    patron_transcriptions = ""
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should not set transcriptions" do
	    patron_transcriptions = " "
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should not set transcriptions" do
	    patron_transcriptions = ";"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should not set transcriptions" do
	    patron_transcriptions = " ; "
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should not set transcriptions" do
	    patron_transcriptions = ";;"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should not set transcriptions" do
	    patron_transcriptions = " ; ; "
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
        end
        describe "word > "do
          it "should set a first transcription" do
	    patron_transcriptions = "test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq "test"
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should set a second transcription" do
	    patron_transcriptions = ";test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq "test"
            list[2][:full_name_transcription].should eq ""
          end
          it "should set a third transcription" do
	    patron_transcriptions = ";;test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq "test"
          end
          it "should not set transcriptions" do
	    patron_transcriptions = ";;;test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq ""
            list[1][:full_name_transcription].should eq ""
            list[2][:full_name_transcription].should eq ""
          end
          it "should set all transcriptions" do
	    patron_transcriptions = "test;test;test;test"
            list = Patron.add_patrons(@patron_names, patron_transcriptions)
            list[0][:full_name].should eq @patron1[:full_name]
            list[1][:full_name].should eq @patron2[:full_name]
            list[2][:full_name].should eq @patron3[:full_name]
            list[0][:full_name_transcription].should eq "test"
            list[1][:full_name_transcription].should eq "test"
            list[2][:full_name_transcription].should eq "test"
          end
        end
      end
    end
    describe "add exist patrons > " do
      before(:each) do
        @patron1 = patrons(:patron_00006)
        @patron2 = patrons(:patron_00007)
        @patron3 = patrons(:patron_00008)
        @patron_names = "#{@patron1.full_name};#{@patron2.full_name};#{@patron3.full_name}"
        @patron_transcriptions = "#{@patron1.full_name_transcription}_test;#{@patron2.full_name_transcription}_test;#{@patron3.full_name_transcription}_test"
      end
      context "not has transcriptions " do
        it "should not exist new patron" do
          list = Patron.add_patrons(@patron_names)
          list.should eq [@patron1, @patron2, @patron3]
          list[0][:full_name].should eq "#{@patron1.full_name}"
          list[1][:full_name].should eq "#{@patron2.full_name}"
          list[2][:full_name].should eq "#{@patron3.full_name}"
          list[0][:full_name_transcription].should eq "#{@patron1.full_name_transcription}"
          list[1][:full_name_transcription].should eq "#{@patron2.full_name_transcription}"
          list[2][:full_name_transcription].should eq "#{@patron3.full_name_transcription}"
        end
      end
      context "not has transcriptions " do
        it "should not exist new patron" do
          list = Patron.add_patrons(@patron_names, @patron_transcriptions)
          list.should eq [@patron1, @patron2, @patron3]
          list[0][:full_name].should eq "#{@patron1.full_name}"
          list[1][:full_name].should eq "#{@patron2.full_name}"
          list[2][:full_name].should eq "#{@patron3.full_name}"
          list[0][:full_name_transcription].should eq "#{@patron1.full_name_transcription}_test"
          list[1][:full_name_transcription].should eq "#{@patron2.full_name_transcription}_test"
          list[2][:full_name_transcription].should eq "#{@patron3.full_name_transcription}_test"
        end
      end
    end
    describe "add new patrons > " do
      before(:each) do
        @time = Time.now
        @patron1 = { full_name: "p_#{@time}_1", full_name_transcription: "p_#{@time}_yomi_1" }
        @patron2 = { full_name: "p_#{@time}_2", full_name_transcription: "p_#{@time}_yomi_2" }
        @patron3 = { full_name: "p_#{@time}_3", full_name_transcription: "p_#{@time}_yomi_3" }
        @patron_names = "#{@patron1[:full_name]};#{@patron2[:full_name]};#{@patron3[:full_name]}"
      end
      context "not has transcriptions " do
        it "should create new patrons" do
          Patron.find_by_full_name(@patron1[:full_name]).should be_nil
          Patron.find_by_full_name(@patron2[:full_name]).should be_nil
          Patron.find_by_full_name(@patron3[:full_name]).should be_nil
          list = Patron.add_patrons(@patron_names)
          p1 = Patron.find_by_full_name(@patron1[:full_name])
          p2 = Patron.find_by_full_name(@patron2[:full_name])
          p3 = Patron.find_by_full_name(@patron3[:full_name])
          p1.should_not be_nil
          p2.should_not be_nil
          p3.should_not be_nil
          list.should eq [p1, p2, p3]
        end
        describe "detail" do
          before(:each) do
            @list = Patron.add_patrons(@patron_names)
            @p1 = Patron.find_by_full_name(@patron1[:full_name])
            @p2 = Patron.find_by_full_name(@patron2[:full_name])
            @p3 = Patron.find_by_full_name(@patron3[:full_name])
          end
          it "should set full_name" do
            @list[0][:full_name].should eq @patron1[:full_name]
            @list[1][:full_name].should eq @patron2[:full_name]
            @list[2][:full_name].should eq @patron3[:full_name]
          end
          it "should set full_name_transcription" do
            @list[0][:full_name_transcription].should eq @p1.full_name_transcription
            @list[1][:full_name_transcription].should eq @p2.full_name_transcription
            @list[2][:full_name_transcription].should eq @p3.full_name_transcription
          end
          it "should set language_id is 1" do
            @list[0][:language_id].should eq 1
            @list[1][:language_id].should eq 1
            @list[2][:language_id].should eq 1
          end
          it "should set Guest's role" do
            @list[0][:required_role_id].should eq Role.find_by_name('Guest').id
            @list[1][:required_role_id].should eq Role.find_by_name('Guest').id
            @list[2][:required_role_id].should eq Role.find_by_name('Guest').id
          end
          it "set exclude_state" do
            system_configuration = SystemConfiguration.find_by_keyname('exclude_patrons')
            system_configuration.v = "#{system_configuration.v}, p_#{@time}_4"
            system_configuration.save
            Rails.cache.clear
            @patron_names += "; 　p_#{@time}_4 　"
            list = Patron.add_patrons(@patron_names)
            list[0][:exclude_state].should eq 0
            list[3][:exclude_state].should eq 1
          end
          it "should exstrip with full size_space" do
            @patron_names += "; 　p_#{@time}_4 　"
            list = Patron.add_patrons(@patron_names)
            list[3][:full_name].should eq "p_#{@time}_4"
          end
        end
      end
      context "not has transcriptions " do
        before(:each) do
          @patron_transcriptions = "#{@patron1[:full_name_transcription]}_test;#{@patron2[:full_name_transcription]}_test;#{@patron3[:full_name_transcription]}_test"
        end
        it "should create new patrons" do
          Patron.find_by_full_name(@patron1[:full_name]).should be_nil
          Patron.find_by_full_name(@patron2[:full_name]).should be_nil
          Patron.find_by_full_name(@patron3[:full_name]).should be_nil
          list = Patron.add_patrons(@patron_names, @patron_transcriptions)
          p1 = Patron.find_by_full_name(@patron1[:full_name])
          p2 = Patron.find_by_full_name(@patron2[:full_name])
          p3 = Patron.find_by_full_name(@patron3[:full_name])
          p1.should_not be_nil
          p2.should_not be_nil
          p3.should_not be_nil
          list.should eq [p1, p2, p3]
        end
        describe "detail" do
          before(:each) do
            @list = Patron.add_patrons(@patron_names, @patron_transcriptions)
            @p1 = Patron.find_by_full_name(@patron1[:full_name])
            @p2 = Patron.find_by_full_name(@patron2[:full_name])
            @p3 = Patron.find_by_full_name(@patron3[:full_name])
          end
          it "should set full_name" do
            @list[0][:full_name].should eq @patron1[:full_name]
            @list[1][:full_name].should eq @patron2[:full_name]
            @list[2][:full_name].should eq @patron3[:full_name]
          end
          it "should set full_name_transcription" do
            @list[0][:full_name_transcription].should eq "#{@patron1[:full_name_transcription]}_test"
            @list[1][:full_name_transcription].should eq "#{@patron2[:full_name_transcription]}_test"
            @list[2][:full_name_transcription].should eq "#{@patron3[:full_name_transcription]}_test"
          end
          it "should set language_id is 1" do
            @list[0][:language_id].should eq 1
            @list[1][:language_id].should eq 1
            @list[2][:language_id].should eq 1
          end
          it "should set Guest's role" do
            @list[0][:required_role_id].should eq Role.find_by_name('Guest').id
            @list[1][:required_role_id].should eq Role.find_by_name('Guest').id
            @list[2][:required_role_id].should eq Role.find_by_name('Guest').id
          end
          it "set exclude_state" do
            system_configuration = SystemConfiguration.find_by_keyname('exclude_patrons')
            system_configuration.v = "#{system_configuration.v}, p_#{@time}_4"
            system_configuration.save
            Rails.cache.clear
            @patron_names += "; 　p_#{@time}_4 　"
            @patron_transcriptions += "; 　p_#{@time}_yomi_4 　"
            list = Patron.add_patrons(@patron_names, @patron_transcriptions)
            list[0][:exclude_state].should eq 0
            list[3][:exclude_state].should eq 1
          end
          it "should exstrip with full size_space" do
            @patron_names += "; 　p_#{@time}_4 　"
            @patron_transcriptions += "; 　p_#{@time}_yomi_4 　"
            list = Patron.add_patrons(@patron_names, @patron_transcriptions)
            list[3][:full_name].should eq "p_#{@time}_4"
          end
        end
      end
    end
  end

  it "should get original_patrons + derived_patrons" do
    patron = FactoryGirl.create(:patron)
    derived_patrons  = patron.derived_patrons  << FactoryGirl.create(:patron)
    original_patrons = patron.original_patrons << FactoryGirl.create(:patron)
    patron.patrons.should eq original_patrons + derived_patrons
  end

  context "when create with user" do
    before(:each) do
      @user = users(:admin)
    end
    it "should new_record" do
      Patron.create_with_user({}, @user).should be_new_record
    end
    it "should has same email with user" do
      Patron.create_with_user({}, @user).email.should eq @user.email
    end
    it "should has Librarian's role" do
      Patron.create_with_user({}, @user).required_role eq Role.find_by_name('Librarian') || nil
    end
    it "should has user local language" do
      Patron.create_with_user({}, @user).language eq Language.find_by_iso_639_1(@user.locale) || nil
    end
  end

  context "when change note" do
    before(:each) do
      @patron = patrons(:patron_00001) 
    end
    context "if change a data" do
      before(:each) do
        @patron.note = "tes_#{@patron.note}"
      end
      it "should update updated_at" do
        note_update_at = @patron.note_update_at
        @patron.change_note
        @patron.note_update_at.should_not eq note_update_at
      end
      it "should update by SYSTEM" do
        User.current_user = nil
        @patron.change_note
        @patron.note_update_by.should eq "SYSTEM"
        @patron.note_update_library.should eq "SYSTEM"
      end 
      it "should update by current_user" do
        User.current_user = users(:admin)
        @patron.change_note
        @patron.note_update_by.should eq User.current_user.patron.full_name
        @patron.note_update_library.should eq User.current_user.library.display_name         
      end
    end
    context "if not change a data" do
      it "shuld return nil" do
        data = @patron.change_note
        data.should eq @patron.note
      end
    end
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

