require 'rails_helper'

describe UserGroupHasCheckoutTypesController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all user_group_has_checkout_types as @user_group_has_checkout_types' do
        get :index
        assigns(:user_group_has_checkout_types).should eq(UserGroupHasCheckoutType.includes([:user_group, :checkout_type]).order('user_groups.position, checkout_types.position').page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all user_group_has_checkout_types as @user_group_has_checkout_types' do
        get :index
        assigns(:user_group_has_checkout_types).should eq(UserGroupHasCheckoutType.includes([:user_group, :checkout_type]).order('user_groups.position, checkout_types.position').page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all user_group_has_checkout_types as @user_group_has_checkout_types' do
        get :index
        assigns(:user_group_has_checkout_types).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all user_group_has_checkout_types as @user_group_has_checkout_types' do
        get :index
        assigns(:user_group_has_checkout_types).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :show, params: { id: user_group_has_checkout_type.id }
        assigns(:user_group_has_checkout_type).should eq(user_group_has_checkout_type)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :show, params: { id: user_group_has_checkout_type.id }
        assigns(:user_group_has_checkout_type).should eq(user_group_has_checkout_type)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :show, params: { id: user_group_has_checkout_type.id }
        assigns(:user_group_has_checkout_type).should eq(user_group_has_checkout_type)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :show, params: { id: user_group_has_checkout_type.id }
        assigns(:user_group_has_checkout_type).should eq(user_group_has_checkout_type)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        get :new
        assigns(:user_group_has_checkout_type).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        get :new
        assigns(:user_group_has_checkout_type).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        get :new
        assigns(:user_group_has_checkout_type).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        get :new
        assigns(:user_group_has_checkout_type).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :edit, params: { id: user_group_has_checkout_type.id }
        assigns(:user_group_has_checkout_type).should eq(user_group_has_checkout_type)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :edit, params: { id: user_group_has_checkout_type.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :edit, params: { id: user_group_has_checkout_type.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
        user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
        get :edit, params: { id: user_group_has_checkout_type.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:user_group_has_checkout_type)
      @invalid_attrs = { user_group_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should be_valid
        end

        it 'redirects to the created patron' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          response.should redirect_to(assigns(:user_group_has_checkout_type))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          assigns(:user_group_has_checkout_type).should_not be_valid
        end

        it 'should be successful' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          response.should be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          assigns(:user_group_has_checkout_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          assigns(:user_group_has_checkout_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_group_has_checkout_type: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user_group_has_checkout_type as @user_group_has_checkout_type' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          assigns(:user_group_has_checkout_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { user_group_has_checkout_type: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
      @attrs = FactoryBot.attributes_for(:user_group_has_checkout_type)
      @invalid_attrs = { user_group_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
        end

        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should eq(@user_group_has_checkout_type)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
        end

        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should eq(@user_group_has_checkout_type)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
        end

        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
          assigns(:user_group_has_checkout_type).should eq(@user_group_has_checkout_type)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested user_group_has_checkout_type as @user_group_has_checkout_type' do
          put :update, params: { id: @user_group_has_checkout_type.id, user_group_has_checkout_type: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @user_group_has_checkout_type = FactoryBot.create(:user_group_has_checkout_type)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested user_group_has_checkout_type' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
      end

      it 'redirects to the user_group_has_checkout_types list' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
        response.should redirect_to(user_group_has_checkout_types_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested user_group_has_checkout_type' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested user_group_has_checkout_type' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested user_group_has_checkout_type' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_group_has_checkout_type.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
