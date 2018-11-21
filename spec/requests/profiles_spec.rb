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
#  save_search_history      :boolean
#  share_bookmarks          :boolean
#  full_name_transcription  :text
#  date_of_birth            :datetime
#

require 'spec_helper'

describe "Profiles" do
  describe "GET /profiles" do
    it "works! (now write some real specs)" do
      get profiles_path
    end
  end
end
