FactoryGirl.define do
  factory :admin, :class => User do |f|
    f.sequence(:username){|n| "admin_#{n}"}
    f.sequence(:email){|n| "admin_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.library_id{FactoryGirl.create(:library).id}
    f.password 'adminpassword'
    f.password_confirmation 'adminpassword'
    f.user_group_id{UserGroup.where(:name => 'user').first.id}
    f.required_role_id{Role.find_by_name('User').id}
    f.locale 'ja'
    f.after(:create) do |user|
      user_has_role = UserHasRole.new
      user_has_role.assign_attributes({:user_id => user.id, :role_id => Role.find_by_name('Administrator').id})
      user_has_role.save
      user.reload
    end
  end

  factory :librarian, :class => User do |f|
    f.sequence(:username){|n| "librarian_#{n}"}
    f.sequence(:email){|n| "librarian_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.library_id{FactoryGirl.create(:library).id}
    f.password 'librarianpassword'
    f.password_confirmation 'librarianpassword'
    f.user_group_id{UserGroup.where(:name => 'user').first.id}
    f.required_role_id{Role.find_by_name('User').id}
    f.locale 'ja'
    f.after(:create) do |user|
      user_has_role = UserHasRole.new
      user_has_role.assign_attributes({:user_id => user.id, :role_id => Role.find_by_name('Librarian').id})
      user_has_role.save
      user.reload
    end
  end

  factory :user, :class => User do |f|
    f.sequence(:username){|n| "user_#{n}"}
    f.sequence(:email){|n| "user_#{n}@example.jp"}
    f.email_confirmation{|u| u.email}
    f.library_id{FactoryGirl.create(:library).id}
    f.password 'userpassword'
    f.password_confirmation 'userpassword'
    f.user_group_id{UserGroup.where(:name => 'not_specified').first.id}
    f.required_role_id{Role.find_by_name('User').id}
    f.locale 'ja'
    f.sequence(:user_number){|n| "user_number_#{n}"}
    f.after(:create) do |user|
      user_has_role = UserHasRole.new
      user_has_role.assign_attributes({:user_id => user.id, :role_id => Role.find_by_name('User').id})
      user_has_role.save
      user.reload
    end
  end

  factory :invalid_user, :class => User do |f|
  end
end
