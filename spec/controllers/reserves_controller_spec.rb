require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ReservesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all reserves as @reserves" do
        get :index
        assigns(:reserves).should eq(Reserve.paginate(:page => 1, :order => ['reserves.expired_at DESC']))
      end
    end

    describe "When not logged in" do
      it "assigns all reserves as @reserves" do
        get :index
        assigns(:reserves).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
