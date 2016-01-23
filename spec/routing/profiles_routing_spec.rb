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

require "spec_helper"

describe ProfilesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { get: "/profiles" }.should route_to(controller: "profiles", action: "index")
    end

    it "recognizes and generates #new" do
      { get: "/profiles/new" }.should route_to(controller: "profiles", action: "new")
    end

    it "recognizes and generates #show" do
      { get: "/profiles/1" }.should route_to(controller: "profiles", action: "show", id: "1")
    end

    it "recognizes and generates #edit" do
      { get: "/profiles/1/edit" }.should route_to(controller: "profiles", action: "edit", id: "1")
    end

    it "recognizes and generates #create" do
      { post: "/profiles" }.should route_to(controller: "profiles", action: "create")
    end

    it "recognizes and generates #update" do
      { put: "/profiles/1" }.should route_to(controller: "profiles", action: "update", id: "1")
    end

    it "recognizes and generates #destroy" do
      { delete: "/profiles/1" }.should route_to(controller: "profiles", action: "destroy", id: "1")
    end

  end
end
