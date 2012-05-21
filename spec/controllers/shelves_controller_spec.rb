require 'spec_helper'

describe ShelvesController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:shelf)
  end

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all shelves as @shelves" do
        get :index
        assigns(:shelves).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all shelves as @shelves" do
        get :index
        assigns(:shelves).should_not be_empty
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all shelves as @shelves" do
        get :index
        assigns(:shelves).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all shelves as @shelves" do
        get :index
        assigns(:shelves).should_not be_empty
        response.should be_success
      end

      it "assigns all shelves as @shelves with library_id" do
        get :index, :library_id => 'kamata'
        assigns(:shelves).should eq(Library.find('kamata').shelves.page(1))
        response.should be_success
      end

      it "assigns all shelves as @shelves with select mode" do
        get :index, :mode => 'select'
        assigns(:shelves).should eq(Shelf.real)
        response.should be_success
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested shelf as @shelf" do
        get :show, :id => 1
        assigns(:shelf).should eq(Shelf.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested shelf as @shelf" do
        get :show, :id => 1
        assigns(:shelf).should eq(Shelf.find(1))
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested shelf as @shelf" do
        get :new
        assigns(:shelf).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested shelf as @shelf" do
        get :new
        assigns(:shelf).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested shelf as @shelf" do
        get :new
        assigns(:shelf).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested shelf as @shelf" do
        get :new
        assigns(:shelf).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested shelf as @shelf" do
        shelf = FactoryGirl.create(:shelf)
        get :edit, :id => shelf.id
        assigns(:shelf).should eq(shelf)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested shelf as @shelf" do
        shelf = FactoryGirl.create(:shelf)
        get :edit, :id => shelf.id
        assigns(:shelf).should eq(shelf)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested shelf as @shelf" do
        shelf = FactoryGirl.create(:shelf)
        get :edit, :id => shelf.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested shelf as @shelf" do
        shelf = FactoryGirl.create(:shelf)
        get :edit, :id => shelf.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created shelf as @shelf" do
          post :create, :shelf => @attrs
          assigns(:shelf).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :shelf => @attrs
          response.should redirect_to(assigns(:shelf))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved shelf as @shelf" do
          post :create, :shelf => @invalid_attrs
          assigns(:shelf).should_not be_valid
        end

        it "should be successful" do
          post :create, :shelf => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created shelf as @shelf" do
          post :create, :shelf => @attrs
          assigns(:shelf).should be_valid
        end

        it "should be forbidden" do
          post :create, :shelf => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved shelf as @shelf" do
          post :create, :shelf => @invalid_attrs
          assigns(:shelf).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :shelf => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created shelf as @shelf" do
          post :create, :shelf => @attrs
          assigns(:shelf).should be_valid
        end

        it "should be forbidden" do
          post :create, :shelf => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved shelf as @shelf" do
          post :create, :shelf => @invalid_attrs
          assigns(:shelf).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :shelf => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created shelf as @shelf" do
          post :create, :shelf => @attrs
          assigns(:shelf).should be_valid
        end

        it "should be forbidden" do
          post :create, :shelf => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved shelf as @shelf" do
          post :create, :shelf => @invalid_attrs
          assigns(:shelf).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :shelf => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @shelf = FactoryGirl.create(:shelf)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
        end

        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
          assigns(:shelf).should eq(@shelf)
        end

        it "moves its position when specified" do
          put :update, :id => @shelf.id, :shelf => @attrs, :move => 'lower'
          response.should redirect_to(library_shelves_url(@shelf.library))
        end
      end

      describe "with invalid params" do
        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
        end

        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
          assigns(:shelf).should eq(@shelf)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
        end

        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
          assigns(:shelf).should eq(@shelf)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested shelf" do
          put :update, :id => @shelf.id, :shelf => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @shelf.id, :shelf => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested shelf as @shelf" do
          put :update, :id => @shelf.id, :shelf => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @shelf = FactoryGirl.create(:shelf)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested shelf" do
        delete :destroy, :id => @shelf.id
      end

      it "redirects to the shelves list" do
        delete :destroy, :id => @shelf.id
        response.should redirect_to(shelves_url)
      end

      it "should not destroy a shelf that has id 1" do
        delete :destroy, :id => 1
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested shelf" do
        delete :destroy, :id => @shelf.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @shelf.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested shelf" do
        delete :destroy, :id => @shelf.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @shelf.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested shelf" do
        delete :destroy, :id => @shelf.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @shelf.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
