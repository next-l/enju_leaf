require "spec_helper"

describe RolesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/roles" }.should route_to(:controller => "roles", :action => "index")
    end

    #it "recognizes and generates #new" do
    #  { :get => "/roles/new" }.should route_to(:controller => "roles", :action => "new")
    #end

    it "recognizes and generates #show" do
      { :get => "/roles/1" }.should route_to(:controller => "roles", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/roles/1/edit" }.should route_to(:controller => "roles", :action => "edit", :id => "1")
    end

    #it "recognizes and generates #create" do
    #  { :post => "/roles" }.should route_to(:controller => "roles", :action => "create")
    #end

    it "recognizes and generates #update" do
      { :put => "/roles/1" }.should route_to(:controller => "roles", :action => "update", :id => "1")
    end

    #it "recognizes and generates #destroy" do
    #  { :delete => "/roles/1" }.should route_to(:controller => "roles", :action => "destroy", :id => "1")
    #end

  end
end
