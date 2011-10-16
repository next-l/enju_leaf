require "spec_helper"

describe SubjectHeadingTypesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/subject_heading_types" }.should route_to(:controller => "subject_heading_types", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/subject_heading_types/new" }.should route_to(:controller => "subject_heading_types", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/subject_heading_types/1" }.should route_to(:controller => "subject_heading_types", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/subject_heading_types/1/edit" }.should route_to(:controller => "subject_heading_types", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/subject_heading_types" }.should route_to(:controller => "subject_heading_types", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/subject_heading_types/1" }.should route_to(:controller => "subject_heading_types", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/subject_heading_types/1" }.should route_to(:controller => "subject_heading_types", :action => "destroy", :id => "1")
    end

  end
end
