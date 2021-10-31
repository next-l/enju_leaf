require 'rails_helper'

describe ManifestationCheckoutStatsController do
  fixtures :all

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:manifestation_checkout_stat)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all manifestation_checkout_stats as @manifestation_checkout_stats' do
        get :index
        assigns(:manifestation_checkout_stats).should eq(ManifestationCheckoutStat.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all manifestation_checkout_stats as @manifestation_checkout_stats' do
        get :index
        assigns(:manifestation_checkout_stats).should eq(ManifestationCheckoutStat.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all manifestation_checkout_stats as @manifestation_checkout_stats' do
        get :index
        assigns(:manifestation_checkout_stats).should eq(ManifestationCheckoutStat.page(1))
      end
    end

    describe 'When not logged in' do
      it 'should not assign manifestation_checkout_stats as @manifestation_checkout_stats' do
        get :index
        assigns(:manifestation_checkout_stats).should eq(ManifestationCheckoutStat.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :show, params: { id: manifestation_checkout_stat.id }
        assigns(:manifestation_checkout_stat).should eq(manifestation_checkout_stat)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :show, params: { id: manifestation_checkout_stat.id }
        assigns(:manifestation_checkout_stat).should eq(manifestation_checkout_stat)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :show, params: { id: manifestation_checkout_stat.id }
        assigns(:manifestation_checkout_stat).should eq(manifestation_checkout_stat)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :show, params: { id: manifestation_checkout_stat.id }
        assigns(:manifestation_checkout_stat).should eq(manifestation_checkout_stat)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        get :new
        assigns(:manifestation_checkout_stat).should_not be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        get :new
        assigns(:manifestation_checkout_stat).should_not be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        get :new
        assigns(:manifestation_checkout_stat).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        get :new
        assigns(:manifestation_checkout_stat).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :edit, params: { id: manifestation_checkout_stat.id }
        assigns(:manifestation_checkout_stat).should eq(manifestation_checkout_stat)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :edit, params: { id: manifestation_checkout_stat.id }
        assigns(:manifestation_checkout_stat).should eq(manifestation_checkout_stat)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :edit, params: { id: manifestation_checkout_stat.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
        manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
        get :edit, params: { id: manifestation_checkout_stat.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:manifestation_checkout_stat)
      @invalid_attrs = { start_date: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should be_valid
          # assigns(:manifestation_checkout_stat).current_state.should eq 'completed'
        end

        it 'redirects to the created manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          response.should redirect_to(manifestation_checkout_stat_url(assigns(:manifestation_checkout_stat)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          assigns(:manifestation_checkout_stat).should_not be_valid
          assigns(:manifestation_checkout_stat).current_state.should eq 'pending'
        end

        it "re-renders the 'new' template" do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should be_valid
        end

        it 'redirects to the created manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          response.should redirect_to(manifestation_checkout_stat_url(assigns(:manifestation_checkout_stat)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          assigns(:manifestation_checkout_stat).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          assigns(:manifestation_checkout_stat).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_checkout_stat: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_checkout_stat as @manifestation_checkout_stat' do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          assigns(:manifestation_checkout_stat).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_checkout_stat: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
      @attrs = FactoryBot.attributes_for(:manifestation_checkout_stat)
      @invalid_attrs = { start_date: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
        end

        it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should eq(@manifestation_checkout_stat)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
        end

        it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should eq(@manifestation_checkout_stat)
          response.should redirect_to(@manifestation_checkout_stat)
        end
      end

      describe 'with invalid params' do
        it 'assigns the manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat, manifestation_checkout_stat: @invalid_attrs }
          assigns(:manifestation_checkout_stat).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @manifestation_checkout_stat, manifestation_checkout_stat: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
        end

        it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
          assigns(:manifestation_checkout_stat).should eq(@manifestation_checkout_stat)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_checkout_stat as @manifestation_checkout_stat' do
          put :update, params: { id: @manifestation_checkout_stat.id, manifestation_checkout_stat: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @manifestation_checkout_stat = FactoryBot.create(:manifestation_checkout_stat)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested manifestation_checkout_stat' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
      end

      it 'redirects to the manifestation_checkout_stats list' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
        response.should redirect_to(manifestation_checkout_stats_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested manifestation_checkout_stat' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
      end

      it 'redirects to the manifestation_checkout_stats list' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
        response.should redirect_to(manifestation_checkout_stats_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested manifestation_checkout_stat' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested manifestation_checkout_stat' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_checkout_stat.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
