FactoryGirl.define do
  factory :profile, :class => Profile do |f|
    f.user_group_id {UserGroup.first.id}
    f.required_role_id {Role.where(name: 'User').first.id}
    f.sequence(:user_number){|n| "user_number_#{n}"}
    f.library_id 2
    f.locale "ja"
    factory :librarian_profile, :class => Profile do |f|
      f.required_role_id {Role.where(name: 'Librarian').first.id}
      f.association :user, factory: :librarian
    end
    factory :admin_profile, :class => Profile do |f|
      f.required_role_id {Role.where(name: 'Administrator').first.id}
      f.association :user, factory: :admin
    end
  end
end
