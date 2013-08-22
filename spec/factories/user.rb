FactoryGirl.define do
  find_or_create_library = proc do |sym|
    attrs = FactoryGirl.attributes_for(sym)
    Library.where(:name => attrs[:name]).first ||
      FactoryGirl.create(sym)
  end

  trait :liba_user do
    library { find_or_create_library.call(:libraryA) }
  end

  trait :libb_user do
    library { find_or_create_library.call(:libraryB) }
  end

  factory :admin, :class => 'User' do |f|
    f.sequence(:username){|n| "admin_#{n}"}
    f.sequence(:email){|n| "admin_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('Administrator')}
    #f.library {Library.find_by_name('web')}
    f.library { FactoryGirl.create(:library) }
    f.password 'adminpassword'
    f.password_confirmation 'adminpassword'
    f.user_group {UserGroup.find_by_name("User")}
    f.required_role {Role.find_by_name('User')}
    f.locale 'ja'
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
    after(:build) {|x| x.patron = FactoryGirl.create(:patron) }


  factory :librarian, :class => 'User' do |f|
    f.sequence(:username){|n| "librarian_#{n}"}
    f.sequence(:email){|n| "librarian_#{n}@example.jp"}
    f.role {Role.find_by_name('Librarian')}
    f.password 'librarianpassword'
    f.password_confirmation 'librarianpassword'
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
  end

  factory :user, :class => 'User' do |f|
    f.sequence(:username){|n| "user_#{n}"}
    f.sequence(:email){|n| "user_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.sequence(:user_number){|n| "user_number_#{n}"}
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
  end

  factory :guest, :class => 'User' do |f|
    f.sequence(:username){|n| "guest_#{n}"}
    f.sequence(:email){|n| "guest_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('Guest')}
    f.library {FactoryGirl.create(:library)}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.user_group {UserGroup.find_by_name("User")}
    f.required_role {Role.find_by_name('Guest')}
    f.locale 'ja'
    f.sequence(:user_number){|n| "user_number_#{n}"}
    f.patron {FactoryGirl.create(:patron)}
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
  end

  factory :invalid_user, :class => 'User' do |f|
  end

  factory :locked_user, :class => 'User' do |f|
    f.sequence(:username){|n| "locked_user_#{n}"}
    f.sequence(:email){|n| "locked_user_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.sequence(:user_number){|n| "locked_user_number_#{n}"}
    f.locked_at {1.week.ago}
  end

  factory :unable_user, :class => 'User' do |f|
    f.sequence(:username){|n| "locked_user_#{n}"}
    f.sequence(:email){|n| "locked_user_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.sequence(:user_number){|n| "unable_user_number_#{n}"}
    f.unable true
  end

  factory :expired_at_is_over_user, :class => 'User' do |f|
    f.sequence(:username){|n| "expired_at_is_over_user_#{n}"}
    f.sequence(:email){|n| "expired_at_is_over_user_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.sequence(:user_number){|n| "expired_at_is_over_user_number_#{n}"}
    f.expired_at {1.week.ago}
  end

  factory :has_not_user_number_user, :class => 'User' do |f|
    f.sequence(:username){|n| "has_not_user_number_user_#{n}"}
    f.sequence(:email){|n| "has_not_user_number_user_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.user_number nil
  end

  factory :adult_user, :class => 'User' do |f|
    liba_user

    f.sequence(:username){|n| "adult_#{n}"}
    f.sequence(:email){|n| "adult_#{n}@example.jp"}
    f.role {Role.find_by_name('Librarian')}
    f.password 'adultpassword'
    f.password_confirmation 'adultpassword'
    f.sequence(:user_number){|n| "adult_user_#{n}"}
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
    after(:build) {|x| x.patron = FactoryGirl.create(:adult_patron) }
  end

  factory :student_user, :class => 'User' do |f|
    liba_user

    f.sequence(:username){|n| "student_#{n}"}
    f.sequence(:email){|n| "student_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'studentpassword'
    f.password_confirmation 'studentpassword'
    f.sequence(:user_number){|n| "student_user_#{n}"}
    after(:build) {|x| x.patron = FactoryGirl.create(:student_patron) }
  end

  factory :juniors_user, :class => 'User' do |f|
    libb_user

    f.sequence(:username){|n| "juniors_#{n}"}
    f.sequence(:email){|n| "juniors_#{n}@example.jp"}
    f.role {Role.find_by_name("Librarian")}
    f.password 'juniorspassword'
    f.password_confirmation 'juniorspassword'
    f.sequence(:user_number){|n| "juniors_user_#{n}"}
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
    after(:build) {|x| x.patron = FactoryGirl.create(:juniors_patron) }
  end

  factory :elements_user, :class => 'User' do |f|
    libb_user

    f.sequence(:username){|n| "elements_#{n}"}
    f.sequence(:email){|n| "elements_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'elementspassword'
    f.password_confirmation 'elementspassword'
    f.patron {FactoryGirl.create(:elements_patron)}
    f.sequence(:user_number){|n| "elements_user_#{n}"}
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
  end

  factory :children_user, :class => 'User' do |f|
    libb_user

    f.sequence(:username){|n| "children_#{n}"}
    f.sequence(:email){|n| "children_#{n}@example.jp"}
    f.role {Role.find_by_name('User')}
    f.password 'childrenpassword'
    f.password_confirmation 'childrenpassword'
    f.patron {FactoryGirl.create(:children_patron)}
    f.sequence(:user_number){|n| "children_user_#{n}"}
    f.user_status {UserStatus.first || FactoryGirl.create(:user_status)}
  end

  end # factory :admin do
end
