require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe InterLibraryLoansController do
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all inter_library_loans as @inter_library_loans" do
        get :index
        assigns(:inter_library_loans).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all inter_library_loans as @inter_library_loans" do
        get :index
        assigns(:inter_library_loans).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns empty as @inter_library_loans" do
        get :index
        assigns(:inter_library_loans).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns empty as @inter_library_loans" do
        get :index
        assigns(:inter_library_loans).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :show, :id => inter_library_loan.id
        assigns(:inter_library_loan).should eq(inter_library_loan)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :show, :id => inter_library_loan.id
        assigns(:inter_library_loan).should eq(inter_library_loan)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :show, :id => inter_library_loan.id
        assigns(:inter_library_loan).should eq(inter_library_loan)
      end
    end

    describe "When not logged in" do
      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :show, :id => inter_library_loan.id
        assigns(:inter_library_loan).should eq(inter_library_loan)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        get :new
        assigns(:inter_library_loan).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        get :new
        assigns(:inter_library_loan).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested inter_library_loan as @inter_library_loan" do
        get :new
        assigns(:inter_library_loan).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inter_library_loan as @inter_library_loan" do
        get :new
        assigns(:inter_library_loan).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :edit, :id => inter_library_loan.id
        assigns(:inter_library_loan).should eq(inter_library_loan)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :edit, :id => inter_library_loan.id
        assigns(:inter_library_loan).should eq(inter_library_loan)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :edit, :id => inter_library_loan.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inter_library_loan as @inter_library_loan" do
        inter_library_loan = FactoryGirl.create(:inter_library_loan)
        get :edit, :id => inter_library_loan.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
