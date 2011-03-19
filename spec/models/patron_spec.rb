# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Patron do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should set a default required_role to Guest" do
    patron = Factory(:patron)
    patron.required_role.should eq Role.find_by_name('Guest')
  end

  it "should set birth_date" do
    patron = Factory(:patron, :birth_date => '2000')
    patron.date_of_birth.should eq Time.zone.parse('2000-01-01')
  end

  it "should set death_date" do
    patron = Factory(:patron, :death_date => '2000')
    patron.date_of_death.should eq Time.zone.parse('2000-01-01')
  end

  it "should not set death_date earlier than birth_date" do
    patron = Factory(:patron, :birth_date => '2010', :death_date => '2000')
    patron.should_not be_valid
  end
end
