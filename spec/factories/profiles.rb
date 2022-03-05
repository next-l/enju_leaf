FactoryBot.define do
  factory :profile, class: Profile do |f|
    f.user_group_id {UserGroup.first.id}
    f.required_role_id {Role.where(name: 'User').first.id}
    f.sequence(:user_number){|n| "user_number_#{n}"}
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
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  user_group_id            :integer
#  library_id               :integer
#  locale                   :string
#  user_number              :string
#  full_name                :text
#  note                     :text
#  keyword_list             :text
#  required_role_id         :integer
#  created_at               :datetime
#  updated_at               :datetime
#  checkout_icalendar_token :string
#  save_checkout_history    :boolean          default(FALSE), not null
#  expired_at               :datetime
#  share_bookmarks          :boolean
#  full_name_transcription  :text
#  date_of_birth            :datetime
#
