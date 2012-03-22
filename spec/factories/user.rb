FactoryGirl.define do
  factory :admin, :class => User do |f|
    f.sequence(:username){|n| "admin_#{n}"}
    f.sequence(:email){|n| "admin_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('Administrator')}
    f.library {FactoryGirl.create(:library)}
    f.password 'adminpassword'
    f.password_confirmation 'adminpassword'
    f.user_group {UserGroup.first}
    f.required_role {Role.find_by_name('User')}
    f.locale 'ja'
    f.patron {FactoryGirl.create(:patron)}
  end

  factory :librarian, :class => User do |f|
    f.sequence(:username){|n| "librarian_#{n}"}
    f.sequence(:email){|n| "librarian_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('Librarian')}
    f.library {FactoryGirl.create(:library)}
    f.password 'librarianpassword'
    f.password_confirmation 'librarianpassword'
    f.user_group {UserGroup.first}
    f.required_role {Role.find_by_name('User')}
    f.locale 'ja'
    f.patron {FactoryGirl.create(:patron)}
  end

  factory :user, :class => User do |f|
    f.sequence(:username){|n| "user_#{n}"}
    f.sequence(:email){|n| "user_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('User')}
    f.library {FactoryGirl.create(:library)}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.user_group {UserGroup.first}
    f.required_role {Role.find_by_name('User')}
    f.locale 'ja'
    f.sequence(:user_number){|n| "user_number_#{n}"}
    f.patron {FactoryGirl.create(:patron)}
  end

  factory :invalid_user, :class => User do |f|
  end

  factory :locked_user, :class => User do |f|
    f.sequence(:username){|n| "locked_user_#{n}"}
    f.sequence(:email){|n| "locked_user_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('User')}
    f.library {FactoryGirl.create(:library)}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.user_group {UserGroup.first}
    f.required_role {Role.find_by_name('User')}
    f.locale 'ja'
    f.sequence(:user_number){|n| "locked_user_number_#{n}"}
    f.patron {FactoryGirl.create(:patron)}
    f.locked_at {1.week.ago}
  end

  factory :expired_at_is_over_user, :class => User do |f|
    f.sequence(:username){|n| "expired_at_is_over_user_#{n}"}
    f.sequence(:email){|n| "expired_at_is_over_user_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.role {Role.find_by_name('User')}
    f.library {FactoryGirl.create(:library)}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.user_group {UserGroup.first}
    f.required_role {Role.find_by_name('User')}
    f.locale 'ja'
    f.sequence(:user_number){|n| "locked_user_number_#{n}"}
    f.patron {FactoryGirl.create(:patron)}
    f.expired_at {1.week.ago}
  end
end
