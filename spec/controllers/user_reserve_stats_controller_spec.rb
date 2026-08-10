require 'rails_helper'

describe UserReserveStatsController do
  fixtures :all

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:user_reserve_stat)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all user_reserve_stats as @user_reserve_stats' do
        get :index
        expect(assigns(:user_reserve_stats)).to eq(UserReserveStat.order('id DESC').page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all user_reserve_stats as @user_reserve_stats' do
        get :index
        expect(assigns(:user_reserve_stats)).to eq(UserReserveStat.order('id DESC').page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all user_reserve_stats as @user_reserve_stats' do
        get :index
        expect(assigns(:user_reserve_stats)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign user_reserve_stats as @user_reserve_stats' do
        get :index
        expect(assigns(:user_reserve_stats)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :show, params: { id: user_reserve_stat.id }
        expect(assigns(:user_reserve_stat)).to eq(user_reserve_stat)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :show, params: { id: user_reserve_stat.id }
        expect(assigns(:user_reserve_stat)).to eq(user_reserve_stat)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :show, params: { id: user_reserve_stat.id }
        expect(assigns(:user_reserve_stat)).to eq(user_reserve_stat)
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :show, params: { id: user_reserve_stat.id }
        expect(assigns(:user_reserve_stat)).to eq(user_reserve_stat)
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        get :new
        expect(assigns(:user_reserve_stat)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        get :new
        expect(assigns(:user_reserve_stat)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested user_reserve_stat as @user_reserve_stat' do
        get :new
        expect(assigns(:user_reserve_stat)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested user_reserve_stat as @user_reserve_stat' do
        get :new
        expect(assigns(:user_reserve_stat)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :edit, params: { id: user_reserve_stat.id }
        expect(assigns(:user_reserve_stat)).to eq(user_reserve_stat)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :edit, params: { id: user_reserve_stat.id }
        expect(assigns(:user_reserve_stat)).to eq(user_reserve_stat)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :edit, params: { id: user_reserve_stat.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested user_reserve_stat as @user_reserve_stat' do
        user_reserve_stat = FactoryBot.create(:user_reserve_stat)
        get :edit, params: { id: user_reserve_stat.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:user_reserve_stat)
      @invalid_attrs = { start_date: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to be_valid
        end

        it 'redirects to the created user_reserve_stat' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(response).to redirect_to(user_reserve_stat_url(assigns(:user_reserve_stat)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(assigns(:user_reserve_stat)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to be_valid
        end

        it 'redirects to the created user_reserve_stat' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(response).to redirect_to(user_reserve_stat_url(assigns(:user_reserve_stat)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(assigns(:user_reserve_stat)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(assigns(:user_reserve_stat)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_reserve_stat: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat' do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(assigns(:user_reserve_stat)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_reserve_stat: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @user_reserve_stat = FactoryBot.create(:user_reserve_stat)
      @attrs = FactoryBot.attributes_for(:user_reserve_stat)
      @invalid_attrs = { start_date: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
        end

        it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to eq(@user_reserve_stat)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
        end

        it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to eq(@user_reserve_stat)
          expect(response).to redirect_to(@user_reserve_stat)
        end
      end

      describe 'with invalid params' do
        it 'assigns the user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat, user_reserve_stat: @invalid_attrs }
          expect(assigns(:user_reserve_stat)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @user_reserve_stat, user_reserve_stat: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
        end

        it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
          expect(assigns(:user_reserve_stat)).to eq(@user_reserve_stat)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_reserve_stat as @user_reserve_stat' do
          put :update, params: { id: @user_reserve_stat.id, user_reserve_stat: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @user_reserve_stat = FactoryBot.create(:user_reserve_stat)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested user_reserve_stat' do
        delete :destroy, params: { id: @user_reserve_stat.id }
      end

      it 'redirects to the user_reserve_stats list' do
        delete :destroy, params: { id: @user_reserve_stat.id }
        expect(response).to redirect_to(user_reserve_stats_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested user_reserve_stat' do
        delete :destroy, params: { id: @user_reserve_stat.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_reserve_stat.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested user_reserve_stat' do
        delete :destroy, params: { id: @user_reserve_stat.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_reserve_stat.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested user_reserve_stat' do
        delete :destroy, params: { id: @user_reserve_stat.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_reserve_stat.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
