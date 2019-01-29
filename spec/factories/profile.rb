FactoryBot.define do
  factory :profile, class: Profile do |f|
    f.user_group_id {UserGroup.first.id}
    f.required_role_id {Role.where(name: 'User').first.id}
    f.sequence(:user_number){|n| "user_number_#{n}"}
    f.library_id { Library.find_by(name: 'kamata').id }
    f.locale { "ja" }
    factory :librarian_profile, class: Profile do |profile|
      profile.required_role_id {Role.find_by(name: 'Librarian').id}
      profile.association :user, factory: :librarian
    end
    factory :admin_profile, class: Profile do |profile|
      profile.required_role_id {Role.find_by(name: 'Administrator').id}
      profile.association :user, factory: :admin
    end
  end
end
