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
          chracters  = %w-! # $ & ' * / = ? ^  ` { | } ~ ( ) < > [ ] : ; @ ,-
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

      describe 'confirmation of email' do
        #validates_confirmation_of :email, :on => :create#, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
        context 'when create user' do
          it '' # TODO: immediately
        end
        #validates_confirmation_of :email, :on => :update, :if => Proc.new { |user| user.email != User.find(user.id).email }
        context 'when update user' do
          it '' # TODO: immediately
        end
      end
    end
    describe 'expired_at' do
      #validates_date :expired_at, :allow_blank => true
      it '' # TODO:
    end

    describe 'patron' do
      # validates_associated :patron
      it '' #TODO
    end
    describe 'user_group' do
      # validates_associated :user_group
      # validates_presence_of :user_group, :library, :locale
      it '' #TODO
    end
    describe 'library' do
      # validates_associated :library
      it '' #TODO
      # validates_presence_of :user_group, :library, :locale
      it '' #TODO
    end
    #validates_presence_of :user_group, :library, :locale

    describe 'user_number' do
      context 'user_number is nil' do
        subject { FactoryGirl.build(:user, :user_number => nil) }
        it      { should be_valid }
      end
      describe 'format' do
        # validates :user_number, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/}, :allow_blank => true
        context 'when format of user_number is correct' do
          shared_examples_for 'create user has user_number of correct format' do
            subject { FactoryGirl.build(:user, :user_number => user_number) }
            it { should be_valid }
          end
          it_behaves_like 'create user has user_number of correct format' do let(:user_number) { '' }           end
          it_behaves_like 'create user has user_number of correct format' do let(:user_number) { ' ' }          end
          it_behaves_like 'create user has user_number of correct format' do let(:user_number) { '0123456789' } end
          it_behaves_like 'create user has user_number of correct format' do let(:user_number) { 'ABCDEFGHIJ' } end
          it_behaves_like 'create user has user_number of correct format' do let(:user_number) { 'klnmopqrst' } end
          it_behaves_like 'create user has user_number of correct format' do let(:user_number) { '_' }          end
        end
        context 'when format of username is wrong' do
          shared_examples_for 'create user has user_number of wrong format' do
            subject { FactoryGirl.build(:user, :user_number => user_number) }
            it { should_not be_valid }
          end
          it_behaves_like 'create user has user_number of wrong format' do let(:user_number) { 'あいうえお' } end
          chracters  = %w_! # $ & ' * / = ? ^  ` { | } ~ ( ) < > [ ] : ; @ , -_
          chracters.map  { |char| it_behaves_like 'create user has user_number of wrong format' do let(:user_number) { "user#{char}00001" } end }
        end
      end
    end

    describe 'password' do
      #with_options :if => :password_required? do |v|
      #v.validates_presence_of     :password
      #v.validates_confirmation_of :password
      #v.validates_length_of       :password, :within => 6..20, :allow_blank => true
      #end

#211   def password_required?
#212     !persisted? || !password.nil? || !password_confirmation.nil?
#213   end
 
      it '' # TODO immediately
    end
  end

  describe '#create' do
    it 'should create an user' do
      FactoryGirl.create(:user)
      #TODO
    end
  end

  describe '#destroy' do
    it 'should destroy an user' do
      user = FactoryGirl.create(:user)
      user.destroy.should be_true
    end
  end

  describe 'solr' do
    it '' #TODO immediately
  end

  describe '#password_required?' do
    it '' #TODO 
  end

  describe '#has_role?' do
=begin
216     return false unless role
217     return true if role.name == role_in_question
218     case role.name
219     when 'Administrator'
220       return true
221     when 'Librarian'
222       return true if role_in_question == 'User'
223     else
224       false
225     end
=end
    it '' #TODO immediately
  end

  describe '#set_role_and_patron' do
    #TODO: 何も return していない。不要なら削除すること
    it ''
  end

  describe '#set_lock_information' do
    it '' #TODO 
  end

  describe '#set_confirmation' do
    it '' #TODO 
  end

  describe '#set_user_number' do
=begin
  253     self.user_number = self.username if SystemConfiguration.get('auto_user_number')
=end
    it '' #TODO immediately
  end 

  describe '#index_patron' do
    it '' #TODO 
  end

  describe '#check_expiration' do
    it '' #TODO 
  end 

  describe '#check_item_before_destroy' do
=begin
271   def check_item_before_destroy
272     # TODO: 貸出記録を残す場合
273     if checkouts.size > 0
274       raise 'This user has items still checked out.'
275     end
276   end
=end
    it '' #TODO immediately
  end

  describe '#check_role_before_destroy' do
=begin
279     if self.has_role?('Administrator')
280       raise 'This is the last administrator in this system.' if Role.find_by_name('Administrator').users.size == 1
281     end
=end
    it '' #TODO immediately
  end

  describe '#set_auto_generated_password' do
    it '' #TODO 
  end

  describe '#reset_checkout_icalendar_token' do
    it '' #TODO 
  end

  describe '#delete_checkout_icalendar_token' do
    it '' #TODO 
  end

  describe '#reset_answer_feed_token' do
    it '' #TODO 
  end

  describe '#delete_answer_feed_token' do
    it '' #TODO 
  end

  describe '.lock_expired_users' do
    it '' #TODO 
  end

  describe '#expired?' do
=begin
312   def expired?
313     if expired_at
314       true if expired_at.beginning_of_day < Time.zone.now.beginning_of_day
315     end
316   end
=end
    it '' #TODO immediately
  end

  describe '#checked_item_count' do
=begin
318   def checked_item_count
319     checkout_count = {}
320     CheckoutType.all.each do |checkout_type|
321       # 資料種別ごとの貸出中の冊数を計算
322       checkout_count[:"#{checkout_type.name}"] = self.checkouts.count_by_sql(["
323         SELECT count(item_id) FROM checkouts
324           WHERE item_id IN (
325             SELECT id FROM items
326               WHERE checkout_type_id = ?
327           )
328           AND user_id = ? AND checkin_id IS NULL", checkout_type.id, self.id]
329       )
330     end
331     return checkout_count
332   end
=end
    it '' #TODO immediately
  end

  describe '#reached_reservation_limit?' do
=begin
334   def reached_reservation_limit?(manifestation)
335     return true if self.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_t    ype).where(:user_group_id => self.user_group.id).collect(&:reservation_limit).max.to_i <= self.reserves.waiting.siz    e
336     false
337   end
=end
    it '' #TODO immediately
  end

  describe '#is_admin?' do
=begin
339   def is_admin?
340     true if self.has_role?('Administrator')
341   end
=end
    it '' #TODO immediately
  end

  describe '#last_librarian?' do
=begin
343   def last_librarian?
344     if self.has_role?('Librarian')
345       role = Role.where(:name => 'Librarian').first
346       true if role.users.size == 1
347     end
348   end
=end
    it '' #TODO immediately
  end

  describe '#send_message' do
    it '' #TODO
  end

  describe '#owned_tags_by_solr' do
    it '' #TODO
  end

  describe '#check_update_own_account' do
    it '' #TODO
  end

  describe '#send_confirmation_instructions' do
    it '' #TODO
  end

  describe '#set_expired_at' do
    it '' #TODO
  end

  describe '#deletable_by' do
=begin
392   def deletable_by(current_user)
393     # 未返却の資料のあるユーザを削除しようとした
394     if self.checkouts.not_returned.count > 0
395       errors[:base] << I18n.t('user.this_user_has_checked_out_item')
396     end
397
398     if self.has_role?('Librarian')
399       # 管理者以外のユーザが図書館員を削除しようとした。図書館員の削除は管理者しかできない
400       unless current_user.has_role?('Administrator')
401         errors[:base] << I18n.t('user.only_administrator_can_destroy')
402       end
403       # 最後の図書館員を削除しようとした
404       if self.last_librarian?
405         errors[:base] << I18n.t('user.last_librarian')
406       end
407     end
408
409     # 最後の管理者を削除しようとした
410     if self.has_role?('Administrator')
411       if Role.where(:name => 'Administrator').first.users.size == 1
412         errors[:base] << I18n.t('user.last_administrator')
413       end
414     end
415
416     if errors[:base] == []
417       true
418     else
419       false
420     end
421   end
=end
    it '' #TODO immediately
  end

  describe '.create_with_params' do
=begin
423   def self.create_with_params(params, has_role_id)
424     logger.debug "create_with_params start."
425     user = User.new
426     user.assign_attributes(params, :as => :admin)
427
428     #puts "****"
429     #puts params
430
431     user_group = UserGroup.find(params[:user_group_id])
432     user.user_group = user_group if user_group
433     user.locale = params[:locale]
434     library = Library.find(params[:library_id])
435     user.library = library if library
436     user.operator = current_user
437
438     logger.debug "create_with_params create-1"
439
440     if params
441       #self.username = params[:user][:login]
442       user.note = params[:note]
443       user.user_group_id = params[:user_group_id] ||= 1
444       user.library_id = params[:library_id] ||= 1
445       # user.role_id = params[:role_id] ||= 1
446
447       if !params[:role_id].blank? and has_role_id.blank?
448         user.role_id = params[:role_id] ||= 1
449         user.role = Role.find(user.role_id)
450       elsif !has_role_id.blank?
451         user.role_id = has_role_id ||= 1
452         user.role = Role.find(has_role_id)
453       else
454         user.role_id = Role.where(:name => 'User').first.id ||= 1
455         user.role = Role.where(:name => 'User').first
456       end
457
458       user.required_role_id = params[:required_role_id] ||= 1
459       user.required_role = Role.find(user.required_role_id)
460       user.keyword_list = params[:keyword_list]
461       user.user_number = params[:user_number]
462       user.locale = params[:locale]
463     end
464
465     logger.debug "create_with_params create-10"
466
467     if user.patron_id
468       user.patron = Patron.find(user.patron_id) rescue nil
469     end
470     logger.debug "create_with_params end."
471     user
472   end
=end
    it '' #TODO immediately
  end

  describe '#update_with_params' do
=begin
474   def update_with_params(params)
475     self.operator = current_user
476     self.openid_identifier = params[:openid_identifier]
477     self.keyword_list = params[:keyword_list]
478     self.checkout_icalendar_token = params[:checkout_icalendar_token]
479     self.email = params[:email]
480     #self.note = params[:note]
481     #self.username = params[:login]
482
483     if current_user.has_role?('Librarian')
484       self.email = params[:email]
485       self.expired_at = params[:expired_at]
486       self.note = params[:note]
487       self.user_group_id = params[:user_group_id] || 1
488       self.library_id = params[:library_id] || 1
489       self.role_id = params[:role_id]
490       self.required_role_id = params[:required_role_id] || 1
491       self.locale = params[:locale]
492       self.user_number = params[:user_number]
493       self.locked = params[:locked]
494       self.expired_at = params[:expired_at]
495       self.unable = params[:unable]
496     end
497     self
498   end
=end
    it '' #TODO immediately
  end

  describe '#deletable?' do
=begin
500   def deletable?
501     true if checkouts.not_returned.empty? and id != 1
502   end
=end
    it '' #TODO immediately
  end

  describe '#set_family' do
    it '' #TODO 
  end

  describe '#out_of_family' do
    it '' #TODO 
  end

  describe '#family' do
    it '' #TODO 
  end

  describe '#user_notice' do
=begin
536   def user_notice
537     @messages = []
538     @messages << I18n.t('user.not_connect', :user => self.username) if self.unable
539     overdues = self.checkouts.overdue(Time.zone.today.beginning_of_day) rescue nil
540     @messages << I18n.t('user.overdue_item', :user => self.username, :count => overdues.length) unless overdues.emp    ty?
541     reserves = self.reserves.hold rescue nil
542     @messages << I18n.t('user.retained_reserve', :user => self.username, :count => reserves.length) unless reserves    .empty?
543     return @messages
544   end
=end
    it '' #TODO immediately
  end

  describe '#set_color' do
    it '' #TODO
  end

  describe '#available_for_reservation?' do
=begin
557   def available_for_reservation?
558     return false if self.user_number.blank? or self.locked_at or (self.expired_at and self.expired_at < Time.zone.t    oday.beginning_of_day)
559     true
560   end
=end
    it '' #TODO immediately
  end

  describe '#delete_reserves' do
=begin
562   def delete_reserves
563     items = []
564     if self.reserves.not_waiting
565       self.reserves.not_waiting.each do |reserve|
566         if reserve.item
567           items << reserve.item
568           Reserve.delete(reserve)
569         end
570       end
571     end
572
573     items.each do |item|
574       item.cancel_retain!
575       item.set_next_reservation if item.manifestation.next_reservation
576     end
577   end
=end
    it '' #TODO immediately
  end

  describe '.set_query' do
=begin
579   def self.set_query(query = nil, birth = nil, add = nil)
580     # query
581     query = query.to_s
582     query = query.gsub("-", "") if query
583     query = "*#{query}*" if query.size == 1
584     # birth date
585     birth_date = birth.to_s.gsub(/\D/, '') if birth
586     message = nil
587     unless birth.blank?
588       begin
589         date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
590       rescue
591         message = I18n.t('user.birth_date_invalid')
592       end
593     end
594     date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil
595     # address
596     address = add
597
598     query = "#{query} date_of_birth_d:[#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
599     query = "#{query} address_text:#{address}" unless address.blank?
600
601     logger.error "query #{query}"
602     logger.error message
603
604     return query, message
605   end
=end
    it '' #TODO immediately
  end

  describe '.set_sort' do
=begin
607   def self.set_sort(sort_by, order)
608     sort = { :sort_by => set_sort_by(sort_by), :order => set_order(order) }
609   end
=end
    it '' #TODO immediately
  end

  describe '.set_sort_by' do
=begin
611   def self.set_sort_by(sort_by)
612     sort = nil
613     case sort_by
614     when 'username'
615       sort = 'username'
616     when 'telephone_number_1'
617       sort = 'telephone_number'
618     when 'full_name'
619       sort = 'full_name'
620     when 'user_number'
621       sort = 'user_number'
622     when 'library'
623       sort = 'library'
624     else
625       sort = 'created_at'
626     end
627   end
=end
    it '' #TODO immediately
  end

  describe '.set_order' do
=begin
629   def self.set_order(order)
630     sort = nil
631     case order
632     when 'asc'
633       sort = 'asc'
634     else 'desc'
635       sort = 'desc'
636     end
637   end
=end
    it '' #TODO immediately
  end

  describe '.output_userlist_pdf' do
    it '' #TODO
  end

  describe '.output_userlist_tsv' do
    it '' #TODO
  end

  describe '#update_with_password' do
=begin
841   def update_with_password(params = {}, *options)
842     User.transaction do
843       self.own_password = true
844       saved = self.original_update_with_password(params, *options)
845       self.own_password = false unless saved
846       return saved
847     end
848   end
=end
    it '' #TODO immediately
  end

  describe '.get_object_method' do
=begin
851   def self.get_object_method(obj,array)
852     _obj = obj.send(array.shift)
853     return get_object_method(_obj, array) if array.present?
854     return _obj
855   end
=end
    it '' #TODO immediately
  end

# TODO:以下、元のテスト
=begin
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
    #query, message = User.set_query('test', '20120707', 'Japan')
    #message.should be_nil
    #query, message = User.set_query('test', 'aaa', 'Japan')
    #message.should_not be_nil 
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

