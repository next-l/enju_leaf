require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe RealizesController do
  fixtures :realizes
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When not logged in" do
      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:realize)
      @invalid_attrs = {:expression_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "redirects to the created realize" do
          post :create, :realize => @attrs
          response.should redirect_to(realize_url(assigns(:realize)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :realize => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "redirects to the created realize" do
          post :create, :realize => @attrs
          response.should redirect_to(realize_url(assigns(:realize)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :realize => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "should be forbidden" do
          post :create, :realize => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :realize => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "should redirect to new_user_session_url" do
          post :create, :realize => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "should redirect to new_user_session_url" do
          post :create, :realize => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @realize = realizes(:realize_00001)
      @attrs = FactoryGirl.attributes_for(:realize)
      @invalid_attrs = {:expression_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @attrs
          assigns(:realize).should eq(@realize)
          response.should redirect_to(@realize)
        end
      end

      describe "with invalid params" do
        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @attrs
          assigns(:realize).should eq(@realize)
          response.should redirect_to(@realize)
        end

        it "moves its position when specified" do
          position = @realize.position
          put :update, :id => @realize.id, :expression_id => @realize.expression.id, :move => 'lower'
          response.should redirect_to expression_realizes_url(@realize.expression)
          assigns(:realize).position.should eq position + 1
        end
      end

      describe "with invalid params" do
        it "assigns the realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @attrs
          assigns(:realize).should eq(@realize)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @realize.id, :realize => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @realize = FactoryGirl.create(:realize)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "redirects to the realizes list" do
        delete :destroy, :id => @realize.id
        response.should redirect_to(realizes_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "redirects to the realizes list" do
        delete :destroy, :id => @realize.id
        response.should redirect_to(realizes_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @realize.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @realize.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
