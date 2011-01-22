require "spec_helper"

describe ItemsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/items" }.should route_to(:controller => "items", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/items/new" }.should route_to(:controller => "items", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/items/1" }.should route_to(:controller => "items", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/items/1/edit" }.should route_to(:controller => "items", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/items" }.should route_to(:controller => "items", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/items/1" }.should route_to(:controller => "items", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/items/1" }.should route_to(:controller => "items", :action => "destroy", :id => "1")
    end

  end
end
