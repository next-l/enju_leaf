# -*- encoding: utf-8 -*-
require 'spec_helper'

describe CarrierType do
  fixtures :carrier_types

  it "should respond to mods_type" do
    carrier_types(:carrier_type_00001).mods_type.should eq 'text'
    carrier_types(:carrier_type_00002).mods_type.should eq 'software, multimedia'
  end
end
