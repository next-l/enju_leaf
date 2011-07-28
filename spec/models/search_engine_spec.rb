# -*- encoding: utf-8 -*-
require 'spec_helper'

describe SearchEngine do
  fixtures :search_engines

  it "should respond to search_params" do
    search_engines(:search_engine_00001).search_params('test').should eq({:submit => 'Search', :locale => 'ja', :keyword => 'test'})
  end
end

# == Schema Information
#
# Table name: search_engines
#
#  id               :integer         not null, primary key
#  name             :string(255)     not null
#  display_name     :text
#  url              :string(255)     not null
#  base_url         :text            not null
#  http_method      :text            not null
#  query_param      :text            not null
#  additional_param :text
#  note             :text
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#

