require 'rails_helper'

describe CiniiBooksController do
  fixtures :all

  it "should be a kind of enju_nii" do
    assert_kind_of Module, EnjuNii
  end

  describe "GET index" do
    login_fixture_admin

    it "should get index", vcr: true do
      get :index, params: { query: 'library' }
      expect(assigns(:books)).not_to be_empty
    end

    it "should be empty if a query is not set", vcr: true do
      get :index, params: { query: '' }
      expect(assigns(:books)).to be_empty
    end
  end
end
