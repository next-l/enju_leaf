require 'spec_helper'

describe SubjectsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all subjects as @subjects" do
        get :index
        assigns(:subjects).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all subjects as @subjects" do
        get :index
        assigns(:subjects).should_not be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested subject as @subject" do
        get :show, :id => 1
        assigns(:subject).should eq(Subject.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested subject as @subject" do
        get :show, :id => 1
        assigns(:subject).should eq(Subject.find(1))
      end
    end
  end
end
