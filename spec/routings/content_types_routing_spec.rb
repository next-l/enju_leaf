require "spec_helper"

describe ContentTypesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/content_types" }.should route_to(:controller => "content_types", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/content_types/new" }.should route_to(:controller => "content_types", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/content_types/1" }.should route_to(:controller => "content_types", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/content_types/1/edit" }.should route_to(:controller => "content_types", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/content_types" }.should route_to(:controller => "content_types", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/content_types/1" }.should route_to(:controller => "content_types", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/content_types/1" }.should route_to(:controller => "content_types", :action => "destroy", :id => "1")
    end

  end
end
