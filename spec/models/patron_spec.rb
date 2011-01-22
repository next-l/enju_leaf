# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Patron do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should set a default required_role to Guest' do
    patron = Factory(:patron)
    patron.required_role.should eq Role.find_by_name('Guest')
  end
end
