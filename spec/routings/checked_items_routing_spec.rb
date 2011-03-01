require "spec_helper"

describe CheckedItemsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/checked_items" }.should route_to(:controller => "checked_items", :action => "index")
    end

    it "recognizes and generates #index" do
      { :get => "/baskets/1/checked_items" }.should route_to(:controller => "checked_items", :action => "index", :basket_id => "1")
    end

    it "recognizes and generates #index" do
      { :get => "/users/1/baskets/1/checked_items" }.should route_to(:controller => "checked_items", :action => "index", :basket_id => "1", :user_id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/checked_items/new" }.should route_to(:controller => "checked_items", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/checked_items/1" }.should route_to(:controller => "checked_items", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/checked_items/1/edit" }.should route_to(:controller => "checked_items", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/checked_items" }.should route_to(:controller => "checked_items", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/checked_items/1" }.should route_to(:controller => "checked_items", :action => "update", :id => "1")
    end

    it "recognizes and generates #update" do
      { :put => "/baskets/1/checked_items/1" }.should route_to(:controller => "checked_items", :action => "update", :id => "1", :basket_id => "1")
    end

    it "recognizes and generates #update" do
      { :put => "/users/1/baskets/1/checked_items/1" }.should route_to(:controller => "checked_items", :action => "update", :id => "1", :basket_id => "1", :user_id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/checked_items/1" }.should route_to(:controller => "checked_items", :action => "destroy", :id => "1")
    end

  end
end
