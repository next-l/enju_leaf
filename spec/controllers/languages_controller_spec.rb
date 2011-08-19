require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe LanguagesController do
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:language)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all languages as @languages" do
        get :index
        assigns(:languages).should eq(Language.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all languages as @languages" do
        get :index
        assigns(:languages).should eq(Language.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all languages as @languages" do
        get :index
        assigns(:languages).should eq(Language.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all languages as @languages" do
        get :index
        assigns(:languages).should eq(Language.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested language as @language" do
        language = FactoryGirl.create(:language)
        get :show, :id => language.id
        assigns(:language).should eq(language)
      end
    end

    describe "When not logged in" do
      it "assigns the requested language as @language" do
        language = FactoryGirl.create(:language)
        get :show, :id => language.id
        assigns(:language).should eq(language)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested language as @language" do
        get :new
        assigns(:language).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested language as @language" do
        get :new
        assigns(:language).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested language as @language" do
        language = FactoryGirl.create(:language)
        get :edit, :id => language.id
        assigns(:language).should eq(language)
      end
    end

    describe "When not logged in" do
      it "should not assign the requested language as @language" do
        language = FactoryGirl.create(:language)
        get :edit, :id => language.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:language)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created language as @language" do
          post :create, :language => @attrs
          assigns(:language).should be_valid
        end

        it "should be forbidden" do
          post :create, :language => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved language as @language" do
          post :create, :language => @invalid_attrs
          assigns(:language).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :language => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created language as @language" do
          post :create, :language => @attrs
          assigns(:language).should be_valid
        end

        it "should be forbidden" do
          post :create, :language => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved language as @language" do
          post :create, :language => @invalid_attrs
          assigns(:language).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :language => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created language as @language" do
          post :create, :language => @attrs
          assigns(:language).should be_valid
        end

        it "should be forbidden" do
          post :create, :language => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved language as @language" do
          post :create, :language => @invalid_attrs
          assigns(:language).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :language => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created language as @language" do
          post :create, :language => @attrs
          assigns(:language).should be_valid
        end

        it "should be forbidden" do
          post :create, :language => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved language as @language" do
          post :create, :language => @invalid_attrs
          assigns(:language).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :language => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @language = FactoryGirl.create(:language)
      @attrs = FactoryGirl.attributes_for(:language)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested language" do
          put :update, :id => @language.id, :language => @attrs
        end

        it "assigns the requested language as @language" do
          put :update, :id => @language.id, :language => @attrs
          assigns(:language).should eq(@language)
        end

        it "moves its position when specified" do
          put :update, :id => @language.id, :language => @attrs, :position => 2
          response.should redirect_to(languages_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested language as @language" do
          put :update, :id => @language.id, :language => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested language" do
          put :update, :id => @language.id, :language => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @language.id, :language => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested language as @language" do
          put :update, :id => @language.id, :language => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @language = FactoryGirl.create(:language)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested language" do
        delete :destroy, :id => @language.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @language.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested language" do
        delete :destroy, :id => @language.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @language.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
