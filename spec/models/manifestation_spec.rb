# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Manifestation do
  fixtures :all

  it "should set pub_date" do
    patron = Factory(:manifestation, :pub_date => '2000')
    patron.date_of_publication.should eq Time.zone.parse('2000-01-01')
  end
end
