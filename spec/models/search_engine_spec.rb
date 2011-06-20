# -*- encoding: utf-8 -*-
require 'spec_helper'

describe SearchEngine do
  fixtures :search_engines

  it "should respond to search_params" do
    search_engines(:search_engine_00001).search_params('test').should eq({:submit => 'Search', :locale => 'ja', :keyword => 'test'})
  end
end
