require 'spec_helper'

describe CheckoutlistsController do
  fixtures :all

  describe "Get index" do
    describe "When logged in as Administorator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:checkoutlists).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:checkoutlists).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:checkoutlists).should be_nil
      end
    end
  
    describe "When not logged in" do
      it "assigns all items as @items" do
        get :index
        assigns(:checkoutlists).should be_nil
      end
    end
  end  
end
