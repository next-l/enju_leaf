require 'spec_helper'

describe LibrariesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all libraries as @libraries" do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all libraries as @libraries" do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested library as @library" do
        get :show, :id => 1
        assigns(:library).should eq(Library.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested library as @library" do
        get :show, :id => 1
        assigns(:library).should eq(Library.find(1))
      end
    end
  end
end
