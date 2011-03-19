require "spec_helper"

describe ManifestationRelationshipsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/manifestation_relationships" }.should route_to(:controller => "manifestation_relationships", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/manifestation_relationships/new" }.should route_to(:controller => "manifestation_relationships", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/manifestation_relationships/1" }.should route_to(:controller => "manifestation_relationships", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/manifestation_relationships/1/edit" }.should route_to(:controller => "manifestation_relationships", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/manifestation_relationships" }.should route_to(:controller => "manifestation_relationships", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/manifestation_relationships/1" }.should route_to(:controller => "manifestation_relationships", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/manifestation_relationships/1" }.should route_to(:controller => "manifestation_relationships", :action => "destroy", :id => "1")
    end

  end
end
