# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create an user' do
    Factory.create(:user)
  end

  it 'should destroy an user' do
    user = Factory.create(:user)
    user.destroy.should be_true
  end

  it 'should respond to has_role(Administrator)' do
    admin = Factory.create(:admin)
    admin.has_role?('Administrator').should be_true
  end

  it 'should respond to has_role(Librarian)' do
    librarian = Factory.create(:librarian)
    librarian.has_role?('Administrator').should be_false
    librarian.has_role?('Librarian').should be_true
    librarian.has_role?('User').should be_true
  end

  it 'should respond to has_role(User)' do
    user = Factory.create(:user)
    user.has_role?('Administrator').should be_false
    user.has_role?('Librarian').should be_false
    user.has_role?('User').should be_true
  end
end
