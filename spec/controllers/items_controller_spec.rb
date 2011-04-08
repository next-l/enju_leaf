require 'spec_helper'

describe ItemsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested item as @item" do
        item = Factory.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested item as @item" do
        item = Factory.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested item as @item" do
        item = Factory.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When not logged in" do
      it "assigns the requested item as @item" do
        item = Factory.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end
  end
end
