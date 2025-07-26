require 'rails_helper'

describe LibraryGroup do
  fixtures :library_groups, :users

  before(:each) do
    @library_group = LibraryGroup.find(1)
  end

  it "should get library_group_config" do
    LibraryGroup.site_config.should be_truthy
  end

  it "should set 1000 as max_number_of_results" do
    expect(LibraryGroup.site_config.max_number_of_results).to eq 1000
  end

  it "should allow access from allowed networks" do
    @library_group.my_networks = "127.0.0.1"
    @library_group.network_access_allowed?("192.168.0.1").should be_falsy
  end

  it "should accept 0 as max_number_of_results" do
    @library_group.update(max_number_of_results: 0).should be_truthy
  end

  it "should serialize settings" do
    expect(@library_group.book_jacket_unknown_resource).to eq 'unknown.png'
  end
end

# == Schema Information
#
# Table name: library_groups
#
#  id                            :bigint           not null, primary key
#  admin_networks                :text
#  allow_bookmark_external_url   :boolean          default(FALSE), not null
#  book_jacket_source            :string
#  csv_charset_conversion        :boolean          default(FALSE), not null
#  display_name                  :text
#  email                         :string
#  family_name_first             :boolean          default(TRUE)
#  footer_banner                 :text
#  html_snippet                  :text
#  login_banner                  :text
#  max_number_of_results         :integer          default(1000)
#  my_networks                   :text
#  name                          :string           not null
#  note                          :text
#  old_login_banner              :text
#  position                      :integer
#  pub_year_facet_range_interval :integer          default(10)
#  screenshot_generator          :string
#  settings                      :jsonb            not null
#  short_name                    :string           not null
#  url                           :string           default("http://localhost:3000/")
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  country_id                    :bigint
#  user_id                       :bigint
#
# Indexes
#
#  index_library_groups_on_email       (email)
#  index_library_groups_on_lower_name  (lower((name)::text)) UNIQUE
#  index_library_groups_on_short_name  (short_name)
#  index_library_groups_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
