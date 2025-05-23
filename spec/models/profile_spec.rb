require 'rails_helper'

describe Profile do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create a profile' do
    FactoryBot.create(:profile)
  end

  it 'should destroy a profile' do
    profile = FactoryBot.create(:profile)
    profile.destroy.should be_truthy
  end

  it 'should not set expired_at if its user group does not have valid period' do
    profile = FactoryBot.create(:profile)
    profile.expired_at.should be_nil
  end

  it 'should set expired_at if its user group has valid period' do
    profile = FactoryBot.build(:profile)
    user_group = FactoryBot.create(:user_group, valid_period_for_new_user: 10)
    user_group.profiles << profile
    profile.user_group.valid_period_for_new_user.should eq 10
    profile.expired_at.should eq 10.days.from_now.end_of_day
  end

  it "should create profile" do
    profile = FactoryBot.create(:profile)
    assert !profile.new_record?, "#{profile.errors.full_messages.to_sentence}"
  end

  it "should create profile with empty user_number" do
    profile1 = FactoryBot.create(:profile, user_number: "")
    profile2 = FactoryBot.create(:profile, user_number: "")
    profile1.should be_valid
    profile2.should be_valid
  end

  if defined?(EnjuCirculation)
    it "should reset checkout_icalendar_token" do
      profiles(:profile_user1).reset_checkout_icalendar_token
      profiles(:profile_user1).checkout_icalendar_token.should be_truthy
    end

    it "should delete checkout_icalendar_token" do
      profiles(:profile_user1).delete_checkout_icalendar_token
      profiles(:profile_user1).checkout_icalendar_token.should be_nil
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
