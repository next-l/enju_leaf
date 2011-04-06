require 'spec_helper'

describe AnswersController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
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
      end
    end
  end
end
