require "spec_helper"

describe RealizesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/realizes" }.should route_to(:controller => "realizes", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/realizes/new" }.should route_to(:controller => "realizes", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/realizes/1" }.should route_to(:controller => "realizes", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/realizes/1/edit" }.should route_to(:controller => "realizes", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/realizes" }.should route_to(:controller => "realizes", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/realizes/1" }.should route_to(:controller => "realizes", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/realizes/1" }.should route_to(:controller => "realizes", :action => "destroy", :id => "1")
    end

  end
end
