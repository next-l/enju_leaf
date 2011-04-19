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
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all checked_items as @checked_items" do
        get :index
        assigns(:checked_items).should_not be_empty
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns empty as @checked_items" do
        get :index
        assigns(:checked_items).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @checked_items" do
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
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested checked_item as @checked_item" do
        get :new
        assigns(:checked_item).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested checked_item as @checked_item" do
        get :new
        assigns(:checked_item).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested checked_item as @checked_item" do
        get :new
        assigns(:checked_item).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checked_item as @checked_item" do
        get :new
        assigns(:checked_item).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        assigns(:checked_item).should eq(checked_item)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        assigns(:checked_item).should eq(checked_item)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
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
