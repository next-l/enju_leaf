require 'spec_helper'

describe MessagesController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin)
        sign_in @user
      end

      it "should get its own messages" do
        get :index
        assigns(:messages).should_not be_nil
        response.should be_success
      end

      describe "When user_id is specified" do
        it "assigns all messages as @messages" do
          get :index, :user_id => @user.username
          assigns(:messages).should_not be_nil
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "should get its own messages" do
        get :index
        assigns(:messages).should_not be_nil
        response.should be_success
      end

      describe "When user_id is specified" do
        it "assigns all messages as @messages" do
          get :index, :user_id => @user.username
          assigns(:messages).should_not be_nil
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "should get its own messages" do
        get :index
        assigns(:messages).should_not be_nil
        response.should be_success
      end

      describe "When user_id is specified" do
        it "assigns all messages as @messages" do
          get :index, :user_id => @user.username
          assigns(:messages).should_not be_nil
        end
      end
    end

    describe "When not logged in" do
      it "assigns all messages as @messages" do
        get :index
        assigns(:messages).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested message as @message" do
        get :new
        assigns(:message).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested message as @message" do
        get :new
        assigns(:message).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested message as @message" do
        get :new
        assigns(:message).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested message as @message" do
        get :new
        assigns(:message).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:recipient => users(:user1).user_number, :subject => 'test',:body => 'test'}
      @invalid_attrs = {:recipient => users(:user1).user_number, :subject => 'test', :body => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created message as @message" do
          post :create, :message => @attrs, :user_id => users(:user1).username
          assigns(:message).should be_valid
        end

        it "redirects to the created message" do
          post :create, :message => @attrs, :user_id => users(:user1).username
          response.should redirect_to(messages_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved message as @message" do
          post :create, :message => @invalid_attrs, :user_id => users(:user1).username
          assigns(:message).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :message => @invalid_attrs, :user_id => users(:user1).username
          response.should render_template("new")
          response.should be_success
        end
      end
    end
  end
end
