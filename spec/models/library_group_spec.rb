# -*- encoding: utf-8 -*-
require 'spec_helper'

describe LibraryGroup do
  fixtures :library_groups

  it "should get library_group_config" do
    LibraryGroup.site_config.should be_true
  end
end


# == Schema Information
#
# Table name: library_groups
#
#  id                          :integer         not null, primary key
#  name                        :string(255)     not null
#  display_name                :text
#  short_name                  :string(255)     not null
#  email                       :string(255)
#  my_networks                 :text
#  login_banner                :text
#  note                        :text
#  country_id                  :integer
#  created_at                  :datetime        not null
#  updated_at                  :datetime        not null
#  admin_networks              :text
#  allow_bookmark_external_url :boolean         default(FALSE), not null
#  position                    :integer
#  url                         :string(255)     default("http://localhost:3000/")
#

