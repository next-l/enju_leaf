require 'spec_helper'

describe PageController do
  fixtures :library_groups, :user_groups, :roles

  describe "GET page" do
    before do
      Manifestation.__elasticsearch__.create_index!
      Manifestation.import
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should get import" do
        get :import
        response.should be_success
      end

      it "should get configuration" do
        get :configuration
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should redirect to user" do
        get :index
        response.should be_success
      end

      it "should not get import" do
        get :import
        response.should be_forbidden
      end

      it "should not get configuration" do
        get :configuration
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should get index" do
        get :index
        response.should be_success
      end

      it "should get opensearch" do
        get :opensearch
        response.should be_success
      end

      it "should get msie_acceralator" do
        get :msie_acceralator
        response.should be_success
      end

      it "should get routing_error" do
        get :routing_error
        response.should be_missing
        response.should render_template("page/404")
      end

      it "should get advanced_search" do
        get :advanced_search
        response.should be_success
        assigns(:libraries).should eq Library.all
      end

      it "should get about" do
        get :about
        response.should be_success
      end

      it "should get add_on" do
        get :add_on
        response.should be_success
      end

      it "should get statistics" do
        get :statistics
        response.should be_success
      end

      it "should not get import" do
        get :import
        response.should redirect_to new_user_session_url
      end

      it "should not get configuration" do
        get :configuration
        response.should redirect_to new_user_session_url
      end
    end
  end
end
