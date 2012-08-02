require 'spec_helper'

describe RetainedManifestationsController do
  fixtures :all

  describe "Get index", :solr => true do
    describe "When logged in as Administorator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all retained_manifestations as @retained_manifestations" do
        get :index
        assigns(:retained_manifestations).should eq(Reserve.retained.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all retained_manifestations as @retained_manifestations" do
        get :index
        assigns(:retained_manifestations).should eq(Reserve.retained.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all retained_manifestations as @retained_manifestations" do
        get :index
        assigns(:retained_manifestations).should be_nil
      end
    end
  
    describe "When not logged in" do
      it "assigns all retained_manifestations as @retained_manifestations" do
        get :index
        assigns(:retained_manifestations).should be_nil
      end
    end
  end  

  describe "Get informed" do
    before(:each) do
      @reserve = FactoryGirl.create(:reserve)
      @attrs = { :id => @reserve.id, :retained => true }
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "updates the requested reserve" do
        put :informed, :id => @reserve.id, :reserve => @attrs
        response.should redirect_to(retained_manifestations_url)
      end
    end    

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "updates the requested reserve" do
        put :informed, :id => @reserve.id, :reserve => @attrs
        response.should redirect_to(retained_manifestations_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "updates the requested reserve" do
        put :informed, :id => @reserve.id, :retained => @retained, :reserve=> @attrs
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "updates the requested reserve" do
        put :informed, :id => @reserve.id, :retained => @retained, :reserve=> @attrs
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
