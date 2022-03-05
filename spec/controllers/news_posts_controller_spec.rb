require 'rails_helper'

describe NewsPostsController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:news_post)
  end

  describe "GET index" do
    before(:each) do
      FactoryBot.create(:news_post)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all news_posts as @news_posts" do
        get :index
        assigns(:news_posts).should eq(NewsPost.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all news_posts as @news_posts" do
        get :index
        assigns(:news_posts).should eq(NewsPost.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all news_posts as @news_posts" do
        get :index
        assigns(:news_posts).should eq(NewsPost.published.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all news_posts as @news_posts" do
        get :index
        assigns(:news_posts).should eq(NewsPost.published.page(1))
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @news_post = FactoryBot.create(:news_post)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested news_post as @news_post" do
        get :show, params: { id: @news_post.id }
        assigns(:news_post).should eq(@news_post)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested news_post as @news_post" do
        get :show, params: { id: @news_post.id }
        assigns(:news_post).should eq(@news_post)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested news_post as @news_post" do
        get :show, params: { id: @news_post.id }
        assigns(:news_post).should eq(@news_post)
      end
    end

    describe "When not logged in" do
      it "assigns the requested news_post as @news_post" do
        get :show, params: { id: @news_post.id }
        assigns(:news_post).should eq(@news_post)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested news_post as @news_post" do
        get :new
        assigns(:news_post).should_not be_valid
        response.should be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested news_post as @news_post" do
        get :new
        assigns(:news_post).should be_nil
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested news_post as @news_post" do
        get :new
        assigns(:news_post).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested news_post as @news_post" do
        get :new
        assigns(:news_post).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @news_post = FactoryBot.create(:news_post)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested news_post as @news_post" do
        get :edit, params: { id: @news_post.id }
        assigns(:news_post).should eq(@news_post)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested news_post as @news_post" do
        get :edit, params: { id: @news_post.id }
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested news_post as @news_post" do
        get :edit, params: { id: @news_post.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested news_post as @news_post" do
        get :edit, params: { id: @news_post.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {body: ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created news_post as @news_post" do
          post :create, params: { news_post: @attrs }
          assigns(:news_post).should be_valid
        end

        it "redirects to the created news_post" do
          post :create, params: { news_post: @attrs }
          response.should redirect_to(assigns(:news_post))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_post as @news_post" do
          post :create, params: { news_post: @invalid_attrs }
          assigns(:news_post).should_not be_valid
        end

        it "should be successful" do
          post :create, params: { news_post: @invalid_attrs }
          response.should be_successful
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created news_post as @news_post" do
          post :create, params: { news_post: @attrs }
          assigns(:news_post).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_post: @attrs }
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_post as @news_post" do
          post :create, params: { news_post: @invalid_attrs }
          assigns(:news_post).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_post: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created news_post as @news_post" do
          post :create, params: { news_post: @attrs }
          assigns(:news_post).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_post: @attrs }
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_post as @news_post" do
          post :create, params: { news_post: @invalid_attrs }
          assigns(:news_post).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_post: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created news_post as @news_post" do
          post :create, params: { news_post: @attrs }
          assigns(:news_post).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_post: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_post as @news_post" do
          post :create, params: { news_post: @invalid_attrs }
          assigns(:news_post).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_post: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @news_post = FactoryBot.create(:news_post)
      @attrs = valid_attributes
      @invalid_attrs = {body: ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
        end

        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
          assigns(:news_post).should eq(@news_post)
        end

        it "moves its position when specified" do
          put :update, params: { id: @news_post.id, news_post: @attrs, move: 'lower' }
          response.should redirect_to(news_posts_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
        end

        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
          assigns(:news_post).should eq(@news_post)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
        end

        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
          assigns(:news_post).should eq(@news_post)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested news_post" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @news_post.id, news_post: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_post as @news_post" do
          put :update, params: { id: @news_post.id, news_post: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @news_post = FactoryBot.create(:news_post)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested news_post" do
        delete :destroy, params: { id: @news_post.id }
      end

      it "redirects to the news_posts list" do
        delete :destroy, params: { id: @news_post.id }
        response.should redirect_to(news_posts_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested news_post" do
        delete :destroy, params: { id: @news_post.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @news_post.id }
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested news_post" do
        delete :destroy, params: { id: @news_post.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @news_post.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested news_post" do
        delete :destroy, params: { id: @news_post.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @news_post.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
