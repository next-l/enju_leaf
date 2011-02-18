# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Frequency do
  fixtures :frequencies

  it "should should have display_name" do
    frequencies(:frequency_00001).display_name.should_not be_nil
  end
end
