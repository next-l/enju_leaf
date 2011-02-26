require "spec_helper"

describe CreatesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/creates" }.should route_to(:controller => "creates", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/creates/new" }.should route_to(:controller => "creates", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/creates/1" }.should route_to(:controller => "creates", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/creates/1/edit" }.should route_to(:controller => "creates", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/creates" }.should route_to(:controller => "creates", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/creates/1" }.should route_to(:controller => "creates", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/creates/1" }.should route_to(:controller => "creates", :action => "destroy", :id => "1")
    end

  end
end
