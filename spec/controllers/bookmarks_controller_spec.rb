require 'spec_helper'

describe BookmarksController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all bookmarks as @bookmarks" do
        get :index
        assigns(:bookmarks).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all bookmarks as @bookmarks" do
        get :index
        assigns(:bookmarks).should be_empty
      end
    end
  end
end
