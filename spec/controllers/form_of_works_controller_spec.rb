require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe FormOfWorksController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:form_of_work)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all form_of_works as @form_of_works" do
        get :index
        assigns(:form_of_works).should eq(FormOfWork.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all form_of_works as @form_of_works" do
        get :index
        assigns(:form_of_works).should eq(FormOfWork.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all form_of_works as @form_of_works" do
        get :index
        assigns(:form_of_works).should eq(FormOfWork.all)
      end
    end

    describe "When not logged in" do
      it "assigns all form_of_works as @form_of_works" do
        get :index
        assigns(:form_of_works).should eq(FormOfWork.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :show, :id => form_of_work.id
        assigns(:form_of_work).should eq(form_of_work)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :show, :id => form_of_work.id
        assigns(:form_of_work).should eq(form_of_work)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :show, :id => form_of_work.id
        assigns(:form_of_work).should eq(form_of_work)
      end
    end

    describe "When not logged in" do
      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :show, :id => form_of_work.id
        assigns(:form_of_work).should eq(form_of_work)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        get :new
        assigns(:form_of_work).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested form_of_work as @form_of_work" do
        get :new
        assigns(:form_of_work).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested form_of_work as @form_of_work" do
        get :new
        assigns(:form_of_work).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested form_of_work as @form_of_work" do
        get :new
        assigns(:form_of_work).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :edit, :id => form_of_work.id
        assigns(:form_of_work).should eq(form_of_work)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :edit, :id => form_of_work.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :edit, :id => form_of_work.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested form_of_work as @form_of_work" do
        form_of_work = FactoryGirl.create(:form_of_work)
        get :edit, :id => form_of_work.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:form_of_work)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created form_of_work as @form_of_work" do
          post :create, :form_of_work => @attrs
          assigns(:form_of_work).should be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved form_of_work as @form_of_work" do
          post :create, :form_of_work => @invalid_attrs
          assigns(:form_of_work).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created form_of_work as @form_of_work" do
          post :create, :form_of_work => @attrs
          assigns(:form_of_work).should be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved form_of_work as @form_of_work" do
          post :create, :form_of_work => @invalid_attrs
          assigns(:form_of_work).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created form_of_work as @form_of_work" do
          post :create, :form_of_work => @attrs
          assigns(:form_of_work).should be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved form_of_work as @form_of_work" do
          post :create, :form_of_work => @invalid_attrs
          assigns(:form_of_work).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created form_of_work as @form_of_work" do
          post :create, :form_of_work => @attrs
          assigns(:form_of_work).should be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved form_of_work as @form_of_work" do
          post :create, :form_of_work => @invalid_attrs
          assigns(:form_of_work).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :form_of_work => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @form_of_work = FactoryGirl.create(:form_of_work)
      @attrs = FactoryGirl.attributes_for(:form_of_work)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
        end

        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
          assigns(:form_of_work).should eq(@form_of_work)
        end

        it "moves its position when specified" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs, :position => 2
          response.should redirect_to(form_of_works_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
        end

        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
          assigns(:form_of_work).should eq(@form_of_work)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
        end

        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
          assigns(:form_of_work).should eq(@form_of_work)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @form_of_work.id, :form_of_work => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested form_of_work as @form_of_work" do
          put :update, :id => @form_of_work.id, :form_of_work => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @form_of_work = FactoryGirl.create(:form_of_work)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested form_of_work" do
        delete :destroy, :id => @form_of_work.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @form_of_work.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested form_of_work" do
        delete :destroy, :id => @form_of_work.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @form_of_work.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested form_of_work" do
        delete :destroy, :id => @form_of_work.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @form_of_work.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested form_of_work" do
        delete :destroy, :id => @form_of_work.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @form_of_work.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
