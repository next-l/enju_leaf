# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  describe 'validates' do
    describe 'username' do
      #validates :username, :presence => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/, :message => I18n.t('errors.messages.en_expected')} 
      context 'when username is correct' do
        subject { FactoryGirl.build(:user, :username => 'test_00001') }
        it { should be_valid }
      end
      context 'when has errores' do
        before do
          @user = FactoryGirl.build(:user, :username => nil)
          @user.valid?
        end
        subject { @user.errors.messages[:username] }
        it('should return error message') { should include(I18n.t('errors.messages.en_expected')) }
      end
      context 'when username is nil' do
        subject { FactoryGirl.build(:user, :username => nil) }
        it { should_not be_valid } 
      end
      context 'when username is wrong format' do
        shared_examples_for 'create user with wrong format' do
          subject { FactoryGirl.build(:user, :username => username) }
          it { should_not be_valid }
        end 
        it_behaves_like 'create user with wrong format' do let(:username) { 'テスト' }     end
        it_behaves_like 'create user with wrong format' do let(:username) { 'test 00001' } end
        it_behaves_like 'create user with wrong format' do let(:username) { 'test-00001' } end
        it_behaves_like 'create user with wrong format' do let(:username) { 'test/00001' } end
        it_behaves_like 'create user with wrong format' do let(:username) { 'test.00001' } end
      end
      #validates_uniqueness_of :username, :unless => proc{|user| SystemConfiguration.get('auto_user_number')}
      context 'when duplication username' do
        shared_examples_for 'system_confiduration set value on auto_user_number' do
          subject { FactoryGirl.build(:user, :username => 'admin') }
          it "check unique" do
            system_configuration = SystemConfiguration.find_by_keyname('auto_user_number')
            system_configuration.v = value
            system_configuration.save
            Rails.cache.clear
            result
          end
        end
        it_behaves_like 'system_confiduration set value on auto_user_number' do
          let(:value)  { 'true' }
          let(:result) { should_not be_valid }
        end 
        it_behaves_like 'system_confiduration set value on auto_user_number' do
          let(:value)  { 'false' }
          let(:result) { should be_valid }
        end 
      end
    end
    describe 'email' do
      context 'email is nil' do
        subject { FactoryGirl.build(:user, :email => nil) }
        it { should be_valid }
      end
      #validates_uniqueness_of :email, :scope => authentication_keys[1..-1], :case_sensitive => false, :allow_blank => true
      describe 'uniquness' do
        context 'when not duplication email' do
          subject { FactoryGirl.build(:user, :email => "#{Time.now.strftime("%m%d%I%M").to_s}@exsample.com") }
          it { should be_valid } 
        end
        context 'when duplication email' do
          subject { FactoryGirl.build(:user, :email => users(:admin).email) }
          it { should_not be_valid } 
        end
        context 'when duplication email is uppercase' do
          subject { FactoryGirl.build(:user, :email => users(:admin).email.upcase) }
          it { should_not be_valid } 
        end
      end
      #validates :email, :format => {:with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i}, :allow_blank => true
      describe 'format' do
        context 'format of email is correct' do
          shared_examples_for 'create user has email of correct format' do
            subject { FactoryGirl.build(:user, :email => email) }
            it { should be_valid }
          end
          it_behaves_like 'create user has email of correct format' do let(:email) { '' }                 end
          it_behaves_like 'create user has email of correct format' do let(:email) { ' ' }                end
          it_behaves_like 'create user has email of correct format' do let(:email) { 'a@example.com' }    end
          it_behaves_like 'create user has email of correct format' do let(:email) { '.@example.com' }    end
          it_behaves_like 'create user has email of correct format' do let(:email) { '%@example.com' }    end
          it_behaves_like 'create user has email of correct format' do let(:email) { '+@example.com' }    end
          it_behaves_like 'create user has email of correct format' do let(:email) { '-@example.com' }    end
          it_behaves_like 'create user has email of correct format' do let(:email) { 'enju@example.jp' }  end
          it_behaves_like 'create user has email of correct format' do let(:email) { 'enju@example.com' } end
        end
        context 'format of email is wrong' do
          shared_examples_for 'create user has email of wrong format' do
            subject { FactoryGirl.build(:user, :email => email) }
            it { should_not be_valid }
          end
          chracters = %w-! # $ & ' * / = ? ^  ` { | } ~ ( ) < > [ ] : ; @ ,-
          chracters2 = %w-! # $ & ' * / = ? ^  ` { | } ~ ( ) < > [ ] : ; @ , . % +-
          it_behaves_like 'create user has email of wrong format' do let(:email) { '@' }              end
          it_behaves_like 'create user has email of wrong format' do let(:email) { '@.' }             end
          it_behaves_like 'create user has email of wrong format' do let(:email) { 'enju@' }          end
          it_behaves_like 'create user has email of wrong format' do let(:email) { 'enju@' }          end
          it_behaves_like 'create user has email of wrong format' do let(:email) { 'enju@example' }   end
          it_behaves_like 'create user has email of wrong format' do let(:email) { 'enju@example.c' } end
          it_behaves_like 'create user has email of wrong format' do let(:email) { 'enjuexample.com' } end
          chracters.map  { |char| it_behaves_like 'create user has email of wrong format' do let(:email) { "#{char}@example.com" }      end }
          chracters2.map { |char| it_behaves_like 'create user has email of wrong format' do let(:email) { "enju@#{char}.com" }         end }
          chracters2.map { |char| it_behaves_like 'create user has email of wrong format' do let(:email) { "enju@example.#{char * 2}" } end }
        end
      end
=begin
TODO: 
      describe 'confirmation of email' do
        #validates_confirmation_of :email, :on => :create#, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
        context 'when create user' do
          context '' do 
            subject { FactoryGirl.build(:user, { email: 'enju@exsample.com', email_confirmation: 'enju@exsample.com' }) }
            it { should be_valid }
          end
        end
        #validates_confirmation_of :email, :on => :update, :if => Proc.new { |user| user.email != User.find(user.id).email }
        context 'when update user' do
        end
      end
=end
    end
    describe 'expired_at' do
      #validates_date :expired_at, :allow_blank => true
    end
  end
=begin
  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => 6..20, :allow_blank => true
  end

  validates_associated :patron, :user_group, :library
  validates_presence_of :user_group, :library, :locale
  validates :user_number, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/}, :allow_blank => true
  before_validation :set_role_and_patron, :on => :create
  before_validation :set_lock_information
  before_validation :set_user_number, :on => :create
  before_destroy :check_item_before_destroy, :check_role_before_destroy
  before_save :check_expiration
  before_create :set_expired_at
  after_destroy :remove_from_index
  after_create :set_confirmation
  after_save :index_patron
  after_destroy :index_patron
=end
=begin
  it 'should create an user' do
    FactoryGirl.create(:user)
  end

  it 'should destroy an user' do
    user = FactoryGirl.create(:user)
    user.destroy.should be_true
  end

  it 'should respond to has_role(Administrator)' do
    admin = FactoryGirl.create(:admin)
    admin.has_role?('Administrator').should be_true
  end

  it 'should respond to has_role(Librarian)' do
    librarian = FactoryGirl.create(:librarian)
    librarian.has_role?('Administrator').should be_false
    librarian.has_role?('Librarian').should be_true
    librarian.has_role?('User').should be_true
  end

  it 'should respond to has_role(User)' do
    user = FactoryGirl.create(:user)
    user.has_role?('Administrator').should be_false
    user.has_role?('Librarian').should be_false
    user.has_role?('User').should be_true
  end

  it 'should lock an user' do
    user = FactoryGirl.create(:user)
    user.locked = '1'
    user.save
    user.active_for_authentication?.should be_false
  end

  it 'should unlock an user' do
    user = FactoryGirl.create(:user)
    user.lock_access!
    user.locked = '0'
    user.save
    user.active_for_authentication?.should be_true
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = FactoryGirl.create(:user)
    user.expired_at.should be_nil
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = FactoryGirl.build(:user)
    user.user_group = FactoryGirl.create(:user_group, :valid_period_for_new_user => 10)
    user.save
    user.expired_at.should eq 10.days.from_now.end_of_day
  end

  it "should create user" do
    user = FactoryGirl.create(:user)
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
  end

  it "should require username" do
    old_count = User.count
    user = FactoryGirl.build(:user, :username => nil)
    user.save
    user.errors[:username].should be_true
    User.count.should eq old_count
  end

  it "should not require user_number" do
    user = FactoryGirl.create(:user, :user_number => nil)
    user.errors[:user_number].should be_empty
  end

  it "should require password" do
    user = FactoryGirl.build(:user, :password => nil)
    user.save
    user.errors[:password].should be_true
  end

  it "should not require password_confirmation on create" do
    user = FactoryGirl.build(:user, :password => 'new_password', :password_confirmation => nil)
    user.save
    user.errors[:email].should be_empty
  end

  it "should not require email on create if an operator is set" do
    user = FactoryGirl.build(:user, :email => '')
    user.operator = FactoryGirl.create(:admin)
    user.save
    user.errors[:email].should be_empty
  end

  it "should reset password" do
    users(:user1).password = 'new password'
    users(:user1).password_confirmation = 'new password'
    users(:user1).save
    users(:user1).valid_password?('new password').should be_true
  end

  it "should reset checkout_icalendar_token" do
    users(:user1).reset_checkout_icalendar_token
    users(:user1).checkout_icalendar_token.should be_true
  end

  it "should reset answer_feed_token" do
    users(:user1).reset_answer_feed_token
    users(:user1).answer_feed_token.should be_true
  end

  it "should delete checkout_icalendar_token" do
    users(:user1).delete_checkout_icalendar_token
    users(:user1).checkout_icalendar_token.should be_nil
  end

  it "should delete answer_feed_token" do
    users(:user1).delete_answer_feed_token
    users(:user1).answer_feed_token.should be_nil
  end

  it "should get checked_item_count" do
    count = users(:user1).checked_item_count
    count.should eq({:book=>2, :serial=>1, :cd=>0})
  end

  it "should set temporary_password" do
    user = users(:user1)
    old_password = user.encrypted_password
    user.set_auto_generated_password
    user.save
    old_password.should_not eq user.encrypted_password
    user.valid_password?('user1password').should be_false
  end

  it "should get reserves_count" do
    users(:user5).reserves.waiting.count.should eq 3
  end

  it "should get highest_role" do
    users(:admin).role.name.should eq 'Administrator'
  end

  it "should send_message" do
    assert users(:librarian1).send_message('reservation_expired_for_patron', :manifestations => users(:librarian1).reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
    users(:librarian1).reload
    users(:librarian1).reserves.not_sent_expiration_notice_to_patron.should be_empty
  end

  it "should lock all expired users" do
    User.lock_expired_users
    users(:user4).active_for_authentication?.should be_false
  end

  it "should lock_expired users" do
    user = users(:user1)
    users(:user1).active_for_authentication?.should be_true
    user.expired_at = 1.day.ago
    user.save
    users(:user1).active_for_authentication?.should be_false
  end

  it "should return messege when user cannot connect" do
    user = FactoryGirl.create(:unable_user)
    user.user_notice.should include(I18n.t('user.not_connect', :user => user.username))
  end

  it "should available for reservation" do
    users(:user1).available_for_reservation?.should be_true
  end

  it "should not available for reservation" do
    FactoryGirl.create(:has_not_user_number_user).available_for_reservation?.should be_false# user_number is blank 
    FactoryGirl.create(:expired_at_is_over_user).available_for_reservation?.should be_false # expired_at is over
    FactoryGirl.create(:locked_user).available_for_reservation?.should be_false # locked_at
  end

  it "should retained when user has retained reserves  was not available for reservation" do
    users(:user1).delete_reserves
    reserves(:reserve_00021).state.should eq 'retained'
  end

  it "should return query" do
    query, message = User.set_query('test', '20120707', 'Japan')
    query.should_not be_nil
  end

  it "should message if input data of birth is wrong" do
    query, message = User.set_query('test', '20120707', 'Japan')
    message.should be_nil
    query, message = User.set_query('test', 'aaa', 'Japan')
    message.should_not be_nil 
  end

  it "should return sort" do
    sort0 = User.set_sort('username', 'asc')
    sort1 = User.set_sort('telephone_number_1', 'asc')
    sort2 = User.set_sort('full_name', 'desc')
    sort3 = User.set_sort('user_number', 'desc')
    sort4 = User.set_sort(nil, nil)

    sort0[:sort_by].should eq 'username'
    sort0[:order].should eq 'asc'
    sort1[:sort_by].should eq 'telephone_number'
    sort1[:order].should eq 'asc'
    sort2[:sort_by].should eq 'full_name'
    sort2[:order].should eq 'desc'
    sort3[:sort_by].should eq 'user_number'
    sort3[:order].should eq 'desc'
    sort4[:sort_by].should eq 'created_at'
    sort4[:order].should eq 'desc'
  end
=end
end

# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  email                    :string(255)     default("")
#  encrypted_password       :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_token           :string(255)
#  remember_created_at      :datetime
#  sign_in_count            :integer         default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  failed_attempts          :integer         default(0)
#  unlock_token             :string(255)
#  locked_at                :datetime
#  authentication_token     :string(255)
#  password_salt            :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  deleted_at               :datetime
#  username                 :string(255)
#  library_id               :integer         default(1), not null
#  user_group_id            :integer         default(1), not null
#  reserves_count           :integer         default(0), not null
#  expired_at               :datetime
#  libraries_count          :integer         default(0), not null
#  bookmarks_count          :integer         default(0), not null
#  checkouts_count          :integer         default(0), not null
#  checkout_icalendar_token :string(255)
#  questions_count          :integer         default(0), not null
#  answers_count            :integer         default(0), not null
#  answer_feed_token        :string(255)
#  due_date_reminder_days   :integer         default(1), not null
#  note                     :text
#  share_bookmarks          :boolean         default(FALSE), not null
#  save_search_history      :boolean         default(FALSE), not null
#  save_checkout_history    :boolean         default(FALSE), not null
#  required_role_id         :integer         default(1), not null
#  keyword_list             :text
#  user_number              :string(255)
#  state                    :string(255)
#  required_score           :integer         default(0), not null
#  locale                   :string(255)
#  openid_identifier        :string(255)
#  oauth_token              :string(255)
#  oauth_secret             :string(255)
#  enju_access_key          :string(255)
#

