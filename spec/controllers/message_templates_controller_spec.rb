require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe MessageTemplatesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:message_template)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all message_templates as @message_templates" do
        get :index
        assigns(:message_templates).should eq(MessageTemplate.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all message_templates as @message_templates" do
        get :index
        assigns(:message_templates).should eq(MessageTemplate.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns empty as @message_templates" do
        get :index
        assigns(:message_templates).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @message_templates" do
        get :index
        assigns(:message_templates).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :show, :id => message_template.id
        assigns(:message_template).should eq(message_template)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :show, :id => message_template.id
        assigns(:message_template).should eq(message_template)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :show, :id => message_template.id
        assigns(:message_template).should eq(message_template)
      end
    end

    describe "When not logged in" do
      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :show, :id => message_template.id
        assigns(:message_template).should eq(message_template)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested message_template as @message_template" do
        get :new
        assigns(:message_template).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested message_template as @message_template" do
        get :new
        assigns(:message_template).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested message_template as @message_template" do
        get :new
        assigns(:message_template).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested message_template as @message_template" do
        get :new
        assigns(:message_template).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :edit, :id => message_template.id
        assigns(:message_template).should eq(message_template)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :edit, :id => message_template.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :edit, :id => message_template.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested message_template as @message_template" do
        message_template = FactoryGirl.create(:message_template)
        get :edit, :id => message_template.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:message_template)
      @invalid_attrs = {:status => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created message_template as @message_template" do
          post :create, :message_template => @attrs
          assigns(:message_template).should be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved message_template as @message_template" do
          post :create, :message_template => @invalid_attrs
          assigns(:message_template).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created message_template as @message_template" do
          post :create, :message_template => @attrs
          assigns(:message_template).should be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved message_template as @message_template" do
          post :create, :message_template => @invalid_attrs
          assigns(:message_template).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created message_template as @message_template" do
          post :create, :message_template => @attrs
          assigns(:message_template).should be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved message_template as @message_template" do
          post :create, :message_template => @invalid_attrs
          assigns(:message_template).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created message_template as @message_template" do
          post :create, :message_template => @attrs
          assigns(:message_template).should be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved message_template as @message_template" do
          post :create, :message_template => @invalid_attrs
          assigns(:message_template).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :message_template => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @message_template = FactoryGirl.create(:message_template)
      @attrs = FactoryGirl.attributes_for(:message_template)
      @invalid_attrs = {:status => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
        end

        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
          assigns(:message_template).should eq(@message_template)
        end

        it "moves its position when specified" do
          put :update, :id => @message_template.id, :message_template => @attrs, :position => 2
          response.should redirect_to(message_templates_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
        end

        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
          assigns(:message_template).should eq(@message_template)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
        end

        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
          assigns(:message_template).should eq(@message_template)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested message_template" do
          put :update, :id => @message_template.id, :message_template => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @message_template.id, :message_template => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested message_template as @message_template" do
          put :update, :id => @message_template.id, :message_template => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @message_template = FactoryGirl.create(:message_template)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested message_template" do
        delete :destroy, :id => @message_template.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @message_template.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested message_template" do
        delete :destroy, :id => @message_template.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @message_template.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested message_template" do
        delete :destroy, :id => @message_template.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @message_template.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested message_template" do
        delete :destroy, :id => @message_template.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @message_template.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
