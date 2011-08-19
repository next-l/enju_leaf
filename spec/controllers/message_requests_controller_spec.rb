require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe MessageRequestsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all message_requests as @message_requests" do
        get :index
        assigns(:message_requests).should eq(MessageRequest.not_sent.order('created_at DESC').page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all message_requests as @message_requests" do
        get :index
        assigns(:message_requests).should eq(MessageRequest.not_sent.order('created_at DESC').page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all message_requests as @message_requests" do
        get :index
        assigns(:message_requests).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all message_requests as @message_requests" do
        get :index
        assigns(:message_requests).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :show, :id => message_request.id
        assigns(:message_request).should eq(message_request)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :show, :id => message_request.id
        assigns(:message_request).should eq(message_request)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :show, :id => message_request.id
        assigns(:message_request).should eq(message_request)
      end
    end

    describe "When not logged in" do
      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :show, :id => message_request.id
        assigns(:message_request).should eq(message_request)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :edit, :id => message_request.id
        assigns(:message_request).should eq(message_request)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :edit, :id => message_request.id
        assigns(:message_request).should eq(message_request)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :edit, :id => message_request.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested message_request as @message_request" do
        message_request = FactoryGirl.create(:message_request)
        get :edit, :id => message_request.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @message_request = FactoryGirl.create(:message_request)
      @attrs = FactoryGirl.attributes_for(:message_request)
      @invalid_attrs = {:sender_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
        end

        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
          assigns(:message_request).should eq(@message_request)
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
        end

        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
          assigns(:message_request).should eq(@message_request)
          response.should redirect_to(@message_request)
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
        end

        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
          assigns(:message_request).should eq(@message_request)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested message_request" do
          put :update, :id => @message_request.id, :message_request => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @message_request.id, :message_request => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_request as @message_request" do
          put :update, :id => @message_request.id, :message_request => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @message_request = FactoryGirl.create(:message_request)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested message_request" do
        delete :destroy, :id => @message_request.id
      end

      it "redirects to the harvesting_requests list" do
        delete :destroy, :id => @message_request.id
        response.should redirect_to(message_requests_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested message_request" do
        delete :destroy, :id => @message_request.id
      end

      it "redirects to the harvesting_requests list" do
        delete :destroy, :id => @message_request.id
        response.should redirect_to(message_requests_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested message_request" do
        delete :destroy, :id => @message_request.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @message_request.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested message_request" do
        delete :destroy, :id => @message_request.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @message_request.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
