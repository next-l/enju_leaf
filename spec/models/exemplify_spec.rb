# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Exemplify do
  fixtures :all

  before(:each) do
    @exemplify = Factory(:exemplify)
  end

  it 'should create lending policy' do
    @exemplify.create_lending_policy
  end
end
