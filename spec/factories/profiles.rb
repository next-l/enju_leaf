FactoryBot.define do
  factory :profile, class: Profile do |f|
    f.user_group_id {UserGroup.first.id}
    f.required_role_id {Role.where(name: 'User').first.id}
    f.sequence(:user_number) {|n| "user_number_#{n}"}
    f.library_id { 2 }
    f.locale { "ja" }
    factory :librarian_profile, class: Profile do |profile|
      profile.required_role_id {Role.where(name: 'Librarian').first.id}
      profile.association :user, factory: :librarian
    end
    factory :admin_profile, class: Profile do |profile|
      profile.required_role_id {Role.where(name: 'Administrator').first.id}
      profile.association :user, factory: :admin
    end
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id                       :bigint           not null, primary key
#  checkout_icalendar_token :string
#  date_of_birth            :datetime
#  expired_at               :datetime
#  full_name                :text
#  full_name_transcription  :text
#  keyword_list             :text
#  locale                   :string
#  note                     :text
#  save_checkout_history    :boolean          default(FALSE), not null
#  share_bookmarks          :boolean
#  user_number              :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  library_id               :bigint
#  required_role_id         :bigint
#  user_group_id            :bigint
#  user_id                  :bigint
#
# Indexes
#
#  index_profiles_on_checkout_icalendar_token  (checkout_icalendar_token) UNIQUE
#  index_profiles_on_library_id                (library_id)
#  index_profiles_on_user_group_id             (user_group_id)
#  index_profiles_on_user_id                   (user_id)
#  index_profiles_on_user_number               (user_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (required_role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#
