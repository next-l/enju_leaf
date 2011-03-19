require "spec_helper"

describe LicensesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/licenses" }.should route_to(:controller => "licenses", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/licenses/new" }.should route_to(:controller => "licenses", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/licenses/1" }.should route_to(:controller => "licenses", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/licenses/1/edit" }.should route_to(:controller => "licenses", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/licenses" }.should route_to(:controller => "licenses", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/licenses/1" }.should route_to(:controller => "licenses", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/licenses/1" }.should route_to(:controller => "licenses", :action => "destroy", :id => "1")
    end

  end
end
