require 'rails_helper'

describe LocSearchController do
  fixtures :all

  it "should be a kind of enju_loc" do
    assert_kind_of Module, EnjuLoc
  end

  describe "GET index" do
    login_fixture_librarian

    it "should get index", vcr: true do
      get :index, params: { query: 'library' }
      expect(assigns(:books)).not_to be_empty
    end

    it "should be empty if a query is not set", vcr: true do
      get :index
      expect(assigns(:books)).to be_empty
    end

    it "should get index with page parameter", vcr: true do
      get :index, params: { query: 'library', page: 2 }
      expect(assigns(:books)).not_to be_empty
    end
  end

  describe "POST create" do
    login_fixture_librarian

    it "should create a bibliographic record if lccn is set", vcr: true do
      post :create, params: { book: {lccn: '2013385616'} }
      expect(assigns(:manifestation).lccn_record.body).to eq '2013385616'
      expect(response).to redirect_to manifestation_url(assigns(:manifestation))
    end

    it "should not create a bibliographic record if lccn is not set", vcr: true do
      post :create, params: { book: { } }
      expect(assigns(:manifestation)).to be_nil
      expect(response).to redirect_to loc_search_index_url
    end
  end
end
