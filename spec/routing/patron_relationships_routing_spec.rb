require "spec_helper"

describe PatronRelationshipsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/patron_relationships" }.should route_to(:controller => "patron_relationships", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/patron_relationships/new" }.should route_to(:controller => "patron_relationships", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/patron_relationships/1" }.should route_to(:controller => "patron_relationships", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/patron_relationships/1/edit" }.should route_to(:controller => "patron_relationships", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/patron_relationships" }.should route_to(:controller => "patron_relationships", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/patron_relationships/1" }.should route_to(:controller => "patron_relationships", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/patron_relationships/1" }.should route_to(:controller => "patron_relationships", :action => "destroy", :id => "1")
    end

  end
end
