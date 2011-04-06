require 'spec_helper'

describe LibraryGroupsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all library_groups as @library_groups" do
        get :index
        assigns(:library_groups).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all library_groups as @library_groups" do
        get :index
        assigns(:library_groups).should_not be_empty
        response.should be_success
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested library_group as @library_group" do
        get :show, :id => 1
        assigns(:library_group).should eq(LibraryGroup.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested library_group as @library_group" do
        get :show, :id => 1
        assigns(:library_group).should eq(LibraryGroup.find(1))
        response.should be_success
      end
    end
  end
end
