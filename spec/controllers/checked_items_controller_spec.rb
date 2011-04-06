require 'spec_helper'

describe CheckedItemsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all checked_items as @checked_items" do
        get :index
        assigns(:checked_items).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all checked_items as @checked_items" do
        get :index
        assigns(:checked_items).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(CheckedItem.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(CheckedItem.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:item_identifier => '00011'}
      @invalid_attrs = {:item_identifier => 'invalid'}
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created checked_item as @checked_item" do
          post :create, :checked_item => @attrs, :basket_id => 3
          assigns(:checked_item).should be_valid
        end
      end
    end
  end
end
