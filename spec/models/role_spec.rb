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
end
