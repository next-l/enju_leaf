require 'spec_helper'

describe FrequenciesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      Factory.create(:frequency)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all frequencies as @frequencies" do
        get :index
        assigns(:frequencies).should eq(Frequency.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all frequencies as @frequencies" do
        get :index
        assigns(:frequencies).should eq(Frequency.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all frequencies as @frequencies" do
        get :index
        assigns(:frequencies).should eq(Frequency.all)
      end
    end

    describe "When not logged in" do
      it "assigns all frequencies as @frequencies" do
        get :index
        assigns(:frequencies).should eq(Frequency.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :show, :id => frequency.id
        assigns(:frequency).should eq(frequency)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :show, :id => frequency.id
        assigns(:frequency).should eq(frequency)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :show, :id => frequency.id
        assigns(:frequency).should eq(frequency)
      end
    end

    describe "When not logged in" do
      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :show, :id => frequency.id
        assigns(:frequency).should eq(frequency)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested frequency as @frequency" do
        get :new
        assigns(:frequency).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested frequency as @frequency" do
        get :new
        assigns(:frequency).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested frequency as @frequency" do
        get :new
        assigns(:frequency).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested frequency as @frequency" do
        get :new
        assigns(:frequency).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :edit, :id => frequency.id
        assigns(:frequency).should eq(frequency)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :edit, :id => frequency.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :edit, :id => frequency.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested frequency as @frequency" do
        frequency = Factory.create(:frequency)
        get :edit, :id => frequency.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:frequency)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created frequency as @frequency" do
          post :create, :frequency => @attrs
          assigns(:frequency).should be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved frequency as @frequency" do
          post :create, :frequency => @invalid_attrs
          assigns(:frequency).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created frequency as @frequency" do
          post :create, :frequency => @attrs
          assigns(:frequency).should be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved frequency as @frequency" do
          post :create, :frequency => @invalid_attrs
          assigns(:frequency).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created frequency as @frequency" do
          post :create, :frequency => @attrs
          assigns(:frequency).should be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved frequency as @frequency" do
          post :create, :frequency => @invalid_attrs
          assigns(:frequency).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created frequency as @frequency" do
          post :create, :frequency => @attrs
          assigns(:frequency).should be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved frequency as @frequency" do
          post :create, :frequency => @invalid_attrs
          assigns(:frequency).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :frequency => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @frequency = Factory(:frequency)
      @attrs = Factory.attributes_for(:frequency)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
        end

        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
          assigns(:frequency).should eq(@frequency)
        end

        it "moves its position when specified" do
          put :update, :id => @frequency.id, :frequency => @attrs, :position => 2
          response.should redirect_to(frequencies_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
        end

        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
          assigns(:frequency).should eq(@frequency)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
        end

        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
          assigns(:frequency).should eq(@frequency)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested frequency" do
          put :update, :id => @frequency.id, :frequency => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @frequency.id, :frequency => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested frequency as @frequency" do
          put :update, :id => @frequency.id, :frequency => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @frequency = Factory(:frequency)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested frequency" do
        delete :destroy, :id => @frequency.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @frequency.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested frequency" do
        delete :destroy, :id => @frequency.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @frequency.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested frequency" do
        delete :destroy, :id => @frequency.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @frequency.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested frequency" do
        delete :destroy, :id => @frequency.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @frequency.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
