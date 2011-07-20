# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Role do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :roles

  it "should not be saved if name is blank" do
    role = Role.first
    role.name = ''
    lambda{role.save!}.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should not be saved if name is not unique" do
    role = Role.first
    lambda{Role.create!(:name => role.name)}.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should respond to localized_name" do
    roles(:role_00001).localized_name.should eq 'Guest'
  end

  it "should respond to default_role" do
    Role.default_role.should eq roles(:role_00001)
  end
end

# == Schema Information
#
# Table name: roles
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :string(255)
#  note         :text
#  created_at   :datetime
#  updated_at   :datetime
#  score        :integer         default(0), not null
#  position     :integer
#

