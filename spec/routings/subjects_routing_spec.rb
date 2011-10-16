require "spec_helper"

describe SubjectsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/subjects" }.should route_to(:controller => "subjects", :action => "index")
    end

    it "recognizes and generates #index" do
      { :get => "/works/1/subjects" }.should route_to(:controller => "subjects", :action => "index", :work_id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/subjects/new" }.should route_to(:controller => "subjects", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/subjects/1" }.should route_to(:controller => "subjects", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/subjects/1/edit" }.should route_to(:controller => "subjects", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/subjects" }.should route_to(:controller => "subjects", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/subjects/1" }.should route_to(:controller => "subjects", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/subjects/1" }.should route_to(:controller => "subjects", :action => "destroy", :id => "1")
    end

  end
end
