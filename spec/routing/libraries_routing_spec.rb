require "spec_helper"

describe LibrariesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/libraries" }.should route_to(:controller => "libraries", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/libraries/new" }.should route_to(:controller => "libraries", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/libraries/1" }.should route_to(:controller => "libraries", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/libraries/1/edit" }.should route_to(:controller => "libraries", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/libraries" }.should route_to(:controller => "libraries", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/libraries/1" }.should route_to(:controller => "libraries", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/libraries/1" }.should route_to(:controller => "libraries", :action => "destroy", :id => "1")
    end

  end
end
