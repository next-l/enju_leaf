require 'spec_helper'

describe AnswersController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all answers as @answers" do
        get :index
        assigns(:answers).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all answers as @answers" do
        get :index
        assigns(:answers).should_not be_empty
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all answers as @answers" do
        get :index
        assigns(:answers).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all answers as @answers" do
        get :index
        assigns(:answers).should_not be_empty
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :show, :id => answer.id
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :show, :id => answer.id
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :show, :id => answer.id
        assigns(:answer).should eq(answer)
      end
    end

    describe "When not logged in" do
      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :show, :id => answer.id
        assigns(:answer).should eq(answer)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested answer as @answer" do
        get :new
        assigns(:answer).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested answer as @answer" do
        get :new
        assigns(:answer).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should assign the requested answer as @answer" do
        get :new
        assigns(:answer).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested answer as @answer" do
        get :new
        assigns(:answer).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :edit, :id => answer.id
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :edit, :id => answer.id
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :edit, :id => answer.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested answer as @answer" do
        answer = FactoryGirl.create(:answer)
        get :edit, :id => answer.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
