require 'spec_helper'

describe TagsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all tags as @tags" do
        get :index
        assigns(:tags).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all tags as @tags" do
        get :index
        assigns(:tags).should_not be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested tag as @tag" do
        get :show, :id => 1
        assigns(:tag).should eq(Tag.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested tag as @tag" do
        get :show, :id => 1
        assigns(:tag).should eq(Tag.find(1))
      end
    end
  end
end
