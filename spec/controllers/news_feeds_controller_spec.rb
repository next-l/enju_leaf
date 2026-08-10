require 'rails_helper'

describe NewsFeedsController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:news_feed)
  end

  describe "GET index" do
    before(:each) do
      FactoryBot.create(:news_feed)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all news_feeds as @news_feeds" do
        get :index
        expect(assigns(:news_feeds)).to eq(NewsFeed.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all news_feeds as @news_feeds" do
        get :index
        expect(assigns(:news_feeds)).to eq(NewsFeed.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns empty as @news_feeds" do
        get :index
        expect(assigns(:news_feeds)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all news_feeds as @news_feeds" do
        get :index
        expect(assigns(:news_feeds)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @news_feed = FactoryBot.create(:news_feed)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested news_feed as @news_feed" do
        get :show, params: { id: @news_feed.id }
        expect(assigns(:news_feed)).to eq(@news_feed)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested news_feed as @news_feed" do
        get :show, params: { id: @news_feed.id }
        expect(assigns(:news_feed)).to eq(@news_feed)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested news_feed as @news_feed" do
        get :show, params: { id: @news_feed.id }
        expect(assigns(:news_feed)).to eq(@news_feed)
      end
    end

    describe "When not logged in" do
      it "assigns the requested news_feed as @news_feed" do
        get :show, params: { id: @news_feed.id }
        expect(assigns(:news_feed)).to eq(@news_feed)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested news_feed as @news_feed" do
        get :new
        expect(assigns(:news_feed)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested news_feed as @news_feed" do
        get :new
        expect(assigns(:news_feed)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested news_feed as @news_feed" do
        get :new
        expect(assigns(:news_feed)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested news_feed as @news_feed" do
        get :new
        expect(assigns(:news_feed)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @news_feed = FactoryBot.create(:news_feed)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested news_feed as @news_feed" do
        get :edit, params: { id: @news_feed.id }
        expect(assigns(:news_feed)).to eq(@news_feed)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested news_feed as @news_feed" do
        get :edit, params: { id: @news_feed.id }
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested news_feed as @news_feed" do
        get :edit, params: { id: @news_feed.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested news_feed as @news_feed" do
        get :edit, params: { id: @news_feed.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { title: '' }
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created news_feed as @news_feed" do
          post :create, params: { news_feed: @attrs }
          expect(assigns(:news_feed)).to be_valid
        end

        it "redirects to the created news_feed" do
          post :create, params: { news_feed: @attrs }
          expect(response).to redirect_to(assigns(:news_feed))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_feed as @news_feed" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(assigns(:news_feed)).not_to be_valid
        end

        it "should be successful" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(response).to be_successful
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created news_feed as @news_feed" do
          post :create, params: { news_feed: @attrs }
          expect(assigns(:news_feed)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_feed: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_feed as @news_feed" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(assigns(:news_feed)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created news_feed as @news_feed" do
          post :create, params: { news_feed: @attrs }
          expect(assigns(:news_feed)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_feed: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_feed as @news_feed" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(assigns(:news_feed)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created news_feed as @news_feed" do
          post :create, params: { news_feed: @attrs }
          expect(assigns(:news_feed)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_feed: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved news_feed as @news_feed" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(assigns(:news_feed)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { news_feed: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @news_feed = FactoryBot.create(:news_feed)
      @attrs = valid_attributes
      @invalid_attrs = { title: '' }
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
        end

        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
          expect(assigns(:news_feed)).to eq(@news_feed)
        end

        it "moves its position when specified" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs, move: 'lower' }
          expect(response).to redirect_to(news_feeds_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
        end

        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
          expect(assigns(:news_feed)).to eq(@news_feed)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
        end

        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
          expect(assigns(:news_feed)).to eq(@news_feed)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @news_feed.id, news_feed: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested news_feed as @news_feed" do
          put :update, params: { id: @news_feed.id, news_feed: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @news_feed = FactoryBot.create(:news_feed)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested news_feed" do
        delete :destroy, params: { id: @news_feed.id }
      end

      it "redirects to the news_feeds list" do
        delete :destroy, params: { id: @news_feed.id }
        expect(response).to redirect_to(news_feeds_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested news_feed" do
        delete :destroy, params: { id: @news_feed.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @news_feed.id }
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested news_feed" do
        delete :destroy, params: { id: @news_feed.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @news_feed.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested news_feed" do
        delete :destroy, params: { id: @news_feed.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @news_feed.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
