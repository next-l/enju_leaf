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
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  checkout_icalendar_token :string
#  save_checkout_history    :boolean          default(FALSE), not null
#  expired_at               :datetime
#  share_bookmarks          :boolean
#  full_name_transcription  :text
#  date_of_birth            :datetime
#
