require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe BookmarkStatsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryBot.create(:bookmark_stat)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all bookmark_stats as @bookmark_stats" do
        get :index
        expect(assigns(:bookmark_stats)).to eq(BookmarkStat.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all bookmark_stats as @bookmark_stats" do
        get :index
        expect(assigns(:bookmark_stats)).to eq(BookmarkStat.page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all bookmark_stats as @bookmark_stats" do
        get :index
        expect(assigns(:bookmark_stats)).to eq(BookmarkStat.page(1))
      end
    end

    describe "When not logged in" do
      it "should not assign bookmark_stats as @bookmark_stats" do
        get :index
        expect(assigns(:bookmark_stats)).to eq(BookmarkStat.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :show, params: { id: bookmark_stat.id }
        expect(assigns(:bookmark_stat)).to eq(bookmark_stat)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :show, params: { id: bookmark_stat.id }
        expect(assigns(:bookmark_stat)).to eq(bookmark_stat)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :show, params: { id: bookmark_stat.id }
        expect(assigns(:bookmark_stat)).to eq(bookmark_stat)
      end
    end

    describe "When not logged in" do
      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :show, params: { id: bookmark_stat.id }
        expect(assigns(:bookmark_stat)).to eq(bookmark_stat)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        get :new
        expect(assigns(:bookmark_stat)).not_to be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        get :new
        expect(assigns(:bookmark_stat)).not_to be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested bookmark_stat as @bookmark_stat" do
        get :new
        expect(assigns(:bookmark_stat)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark_stat as @bookmark_stat" do
        get :new
        expect(assigns(:bookmark_stat)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :edit, params: { id: bookmark_stat.id }
        expect(assigns(:bookmark_stat)).to eq(bookmark_stat)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :edit, params: { id: bookmark_stat.id }
        expect(assigns(:bookmark_stat)).to eq(bookmark_stat)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :edit, params: { id: bookmark_stat.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryBot.create(:bookmark_stat)
        get :edit, params: { id: bookmark_stat.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:bookmark_stat)
      @invalid_attrs = {start_date: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to be_valid
        end

        it "redirects to the created bookmark_stat" do
          post :create, params: { bookmark_stat: @attrs }
          expect(response).to redirect_to(bookmark_stat_url(assigns(:bookmark_stat)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(assigns(:bookmark_stat)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to be_valid
        end

        it "redirects to the created bookmark_stat" do
          post :create, params: { bookmark_stat: @attrs }
          expect(response).to redirect_to(bookmark_stat_url(assigns(:bookmark_stat)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(assigns(:bookmark_stat)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { bookmark_stat: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(assigns(:bookmark_stat)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { bookmark_stat: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(assigns(:bookmark_stat)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { bookmark_stat: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @bookmark_stat = FactoryBot.create(:bookmark_stat)
      @attrs = FactoryBot.attributes_for(:bookmark_stat)
      @invalid_attrs = {start_date: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
        end

        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to eq(@bookmark_stat)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
        end

        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to eq(@bookmark_stat)
          expect(response).to redirect_to(@bookmark_stat)
        end
      end

      describe "with invalid params" do
        it "assigns the bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat, bookmark_stat: @invalid_attrs }
          expect(assigns(:bookmark_stat)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @bookmark_stat, bookmark_stat: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
        end

        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
          expect(assigns(:bookmark_stat)).to eq(@bookmark_stat)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, params: { id: @bookmark_stat.id, bookmark_stat: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @bookmark_stat = FactoryBot.create(:bookmark_stat)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested bookmark_stat" do
        delete :destroy, params: { id: @bookmark_stat.id }
      end

      it "redirects to the bookmark_stats list" do
        delete :destroy, params: { id: @bookmark_stat.id }
        expect(response).to redirect_to(bookmark_stats_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested bookmark_stat" do
        delete :destroy, params: { id: @bookmark_stat.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @bookmark_stat.id }
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested bookmark_stat" do
        delete :destroy, params: { id: @bookmark_stat.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @bookmark_stat.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested bookmark_stat" do
        delete :destroy, params: { id: @bookmark_stat.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @bookmark_stat.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
