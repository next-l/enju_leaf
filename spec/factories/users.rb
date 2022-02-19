FactoryBot.define do
  factory :admin, class: User do |f|
    f.sequence(:username){|n| "admin_#{n}"}
    f.sequence(:email){|n| "admin_#{n}@example.jp"}
    f.password { 'adminpassword' }
    f.password_confirmation { 'adminpassword' }
    f.after(:create) do |user|
      user_has_role = UserHasRole.new
      user_has_role.assign_attributes({user_id: user.id, role_id: Role.find_by(name: 'Administrator').id})
      user_has_role.save
      user.reload
    end
  end

  factory :librarian, class: User do |f|
    f.sequence(:username){|n| "librarian_#{n}"}
    f.sequence(:email){|n| "librarian_#{n}@example.jp"}
    f.password { 'librarianpassword' }
    f.password_confirmation { 'librarianpassword' }
    f.after(:create) do |user|
      user_has_role = UserHasRole.new
      user_has_role.assign_attributes({user_id: user.id, role_id: Role.find_by(name: 'Librarian').id})
      user_has_role.save
      user.reload
    end
  end

  factory :user, class: User do |f|
    f.sequence(:username){|n| "user_#{n}"}
    f.sequence(:email){|n| "user_#{n}@example.jp"}
    f.password { 'userpassword' }
    f.password_confirmation { 'userpassword' }
    f.after(:create) do |user|
      user_has_role = UserHasRole.new
      user_has_role.assign_attributes({user_id: user.id, role_id: Role.find_by(name: 'User').id})
      user_has_role.save
      user.reload
    end
  end

  factory :invalid_user, class: User do |f|
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  deleted_at             :datetime
#  expired_at             :datetime
#  failed_attempts        :integer          default(0)
#  unlock_token           :string
#  locked_at              :datetime
#  confirmed_at           :datetime
#  answer_feed_token      :string
#
