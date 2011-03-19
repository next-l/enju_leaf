require "spec_helper"

describe CheckoutTypesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/checkout_types" }.should route_to(:controller => "checkout_types", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/checkout_types/new" }.should route_to(:controller => "checkout_types", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/checkout_types/1" }.should route_to(:controller => "checkout_types", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/checkout_types/1/edit" }.should route_to(:controller => "checkout_types", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/checkout_types" }.should route_to(:controller => "checkout_types", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/checkout_types/1" }.should route_to(:controller => "checkout_types", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/checkout_types/1" }.should route_to(:controller => "checkout_types", :action => "destroy", :id => "1")
    end

  end
end
