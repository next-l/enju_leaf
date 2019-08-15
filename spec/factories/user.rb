FactoryBot.define do
  factory :admin, class: User do
    sequence(:username){|n| "admin_#{n}"}
    sequence(:email){|n| "admin_#{n}@example.jp"}
    password { 'adminpassword' }
    password_confirmation { 'adminpassword' }
    association :profile
    after(:create) do |user|
      user.role = Role.find_by(name: 'Administrator')
    end
  end

  factory :librarian, class: User do
    sequence(:username){|n| "librarian_#{n}"}
    sequence(:email){|n| "librarian_#{n}@example.jp"}
    password { 'librarianpassword' }
    password_confirmation { 'librarianpassword' }
    association :profile
    after(:create) do |user|
      user.role = Role.find_by(name: 'Librarian')
    end
  end

  factory :user, class: User do
    sequence(:username){|n| "user_#{n}"}
    sequence(:email){|n| "user_#{n}@example.jp"}
    password { 'userpassword' }
    password_confirmation { 'userpassword' }
    association :profile
    after(:create) do |user|
      user.role = Role.find_by(name: 'User')
    end
  end

  factory :invalid_user, class: User do
  end
end
