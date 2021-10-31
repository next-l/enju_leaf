require 'rails_helper'

describe NdlBooksController do
  fixtures :all

  it "should be a kind of enju_ndl" do
    assert_kind_of Module, EnjuNdl
  end

  describe "GET index" do
    login_fixture_admin

    it "should get index", vcr: true do
      get :index, params: { query: 'library' }
      assigns(:books).should_not be_empty
    end

    it "should be empty if a query is not set", vcr: true do
      get :index
      assigns(:books).should be_empty
    end
  end

  describe "POST create" do
    login_fixture_admin

    it "should create a bibliographic record if jpno is set", vcr: true do
      post :create, params: { book: {iss_itemno: 'R100000002-I000002539673-00'} }
      assigns(:manifestation).identifier_contents(:jpno).should eq ['97024234']
      response.should redirect_to manifestation_url(assigns(:manifestation))
    end

    it "should not create a bibliographic record if jpno is not set", vcr: true do
      post :create, params: { book: {jpno: nil} }
      assigns(:manifestation).should be_nil
      response.should redirect_to ndl_books_url
    end

    it "should create a serial record", vcr: true do
      post :create, params: { book: {iss_itemno: 'R100000002-I000000029371-00'} }
      assigns(:manifestation).identifier_contents(:jpno).should eq ['00029793']
      response.should redirect_to manifestation_url(assigns(:manifestation))
    end
  end
end
