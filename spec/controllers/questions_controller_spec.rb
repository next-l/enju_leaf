require 'spec_helper'

describe QuestionsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested question as @question" do
        question = Factory.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested question as @question" do
        question = Factory.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested question as @question" do
        question = Factory.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When not logged in" do
      it "assigns the requested question as @question" do
        question = Factory.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should assign the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
