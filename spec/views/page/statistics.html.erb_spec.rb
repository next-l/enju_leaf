# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "page/statistics" do
  fixtures :all

  before(:each) do
    @profile = assign(:profile, profiles(:admin))
    view.stub(:current_user).and_return(User.find('enjuadmin'))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Statistics/)
  end
end
