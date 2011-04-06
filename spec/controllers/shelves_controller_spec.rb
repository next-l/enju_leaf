require 'spec_helper'

describe ShelvesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all shelves as @shelves" do
        get :index
        assigns(:shelves).should eq(Shelf.paginate(:page => 1))
      end
    end

    describe "When not logged in" do
      it "assigns all shelves as @shelves" do
        get :index
        assigns(:shelves).should eq(Shelf.paginate(:page => 1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested shelf as @shelf" do
        get :show, :id => 1
        assigns(:shelf).should eq(Shelf.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested shelf as @shelf" do
        get :show, :id => 1
        assigns(:shelf).should eq(Shelf.find(1))
      end
    end
  end
end
