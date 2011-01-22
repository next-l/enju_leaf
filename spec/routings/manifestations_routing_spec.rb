require "spec_helper"

describe ManifestationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/manifestations" }.should route_to(:controller => "manifestations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/manifestations/new" }.should route_to(:controller => "manifestations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/manifestations/1" }.should route_to(:controller => "manifestations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/manifestations/1/edit" }.should route_to(:controller => "manifestations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/manifestations" }.should route_to(:controller => "manifestations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/manifestations/1" }.should route_to(:controller => "manifestations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/manifestations/1" }.should route_to(:controller => "manifestations", :action => "destroy", :id => "1")
    end

  end
end
