require 'rails_helper'

describe BasketsController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all baskets as @baskets' do
        get :index, params: { user_id: users(:user1).username }
        expect(assigns(:baskets)).not_to be_empty
        expect(response).to be_successful
      end

      it 'should get index without user_id' do
        get :index
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all baskets as @baskets' do
        get :index, params: { user_id: users(:user1).username }
        expect(assigns(:baskets)).not_to be_empty
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all baskets as @baskets' do
        get :index, params: { user_id: users(:user1).username }
        expect(assigns(:baskets)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all baskets as @baskets' do
        get :index, params: { user_id: users(:user1).username }
        expect(assigns(:baskets)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested basket as @basket' do
        get :show, params: { id: 1, user_id: users(:admin).username }
        expect(assigns(:basket)).to eq(Basket.find(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested basket as @basket' do
        get :show, params: { id: 1, user_id: users(:admin).username }
        expect(assigns(:basket)).to eq(Basket.find(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested basket as @basket' do
        get :show, params: { id: 1, user_id: users(:admin).username }
        expect(assigns(:basket)).to eq(Basket.find(1))
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested basket as @basket' do
        get :show, params: { id: 1, user_id: users(:admin).username }
        expect(assigns(:basket)).to eq(Basket.find(1))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested basket as @basket' do
        get :new
        expect(assigns(:basket)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested basket as @basket' do
        get :new
        expect(assigns(:basket)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested basket as @basket' do
        get :new
        expect(assigns(:basket)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested basket as @basket' do
        get :new
        expect(assigns(:basket)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin
      before(:each) do
        @basket = baskets(:basket_00001)
      end

      it 'assigns the requested basket as @basket' do
        get :edit, params: { id: @basket.id }
        expect(assigns(:basket)).to eq(@basket)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian
      before(:each) do
        @basket = baskets(:basket_00001)
      end

      it 'assigns the requested basket as @basket' do
        get :edit, params: { id: @basket.id }
        expect(assigns(:basket)).to eq(@basket)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user
      before(:each) do
        @basket = baskets(:basket_00001)
      end

      it 'should not assign the requested basket as @basket' do
        get :edit, params: { id: @basket.id }
        expect(assigns(:basket)).to eq(@basket)
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      before(:each) do
        @basket = baskets(:basket_00001)
      end

      it 'should not assign the requested basket as @basket' do
        get :edit, params: { id: @basket.id }
        expect(assigns(:basket)).to eq(@basket)
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = { user_number: users(:user1).profile.user_number }
      @invalid_attrs = { user_number: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: { user_number: users(:user1).profile.user_number } }
          expect(assigns(:basket)).to be_valid
        end
      end

      describe 'with blank params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: { note: 'test' } }
          expect(assigns(:basket)).not_to be_valid
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: @invalid_attrs }
          expect(assigns(:basket)).not_to be_valid
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: { user_number: users(:user1).profile.user_number } }
          expect(assigns(:basket)).to be_valid
        end
      end

      describe 'with blank params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: { note: 'test' } }
          expect(assigns(:basket)).not_to be_valid
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: @invalid_attrs }
          expect(assigns(:basket)).not_to be_valid
        end
      end

      it 'should not create basket when user is suspended' do
        post :create, params: { basket: { user_number: users(:user4).profile.user_number } }
        expect(assigns(:basket)).not_to be_valid
        expect(assigns(:basket).errors['base'].include?(I18n.t('basket.this_account_is_suspended'))).to be_truthy
        expect(response).to be_successful
      end

      it 'should not create basket when user is not found' do
        post :create, params: { basket: { user_number: 'not found' } }
        expect(assigns(:basket)).not_to be_valid
        expect(assigns(:basket).errors['base'].include?(I18n.t('user.not_found'))).to be_truthy
        expect(response).to be_successful
      end

      it 'should not create basket without user_number' do
        post :create, params: { basket: { note: 'test' } }
        expect(assigns(:basket)).not_to be_valid
        expect(response).to be_successful
      end

      it 'should create basket' do
        post :create, params: { basket: { user_number: users(:user1).profile.user_number } }
        expect(assigns(:basket)).to be_valid
        expect(response).to redirect_to new_checked_item_url(basket_id: assigns(:basket).id)
      end

      it 'should not create basket without user_number' do
        post :create, params: { basket: { note: 'test' } }
        expect(assigns(:basket)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: { user_number: users(:user1).profile.user_number } }
          expect(assigns(:basket)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { basket: { user_number: users(:user1).profile.user_number } }
          expect(response).to be_forbidden
        end
      end

      it 'should not create basket' do
        post :create, params: { basket: { user_number: users(:user1).profile.user_number } }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with blank params' do
        it 'assigns a newly created basket as @basket' do
          post :create, params: { basket: { note: 'test' } }
          expect(assigns(:basket)).to be_nil
        end

        it 'should be redirected to new_user_session_url' do
          post :create, params: { basket: { note: 'test' } }
          expect(assigns(:basket)).to be_nil
          assert_response :redirect
          expect(response).to redirect_to new_user_session_url
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @attrs = { user_id: users(:user1).username }
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested basket' do
          put :update, params: { id: 8, basket: @attrs }
        end

        it 'assigns the requested basket as @basket' do
          put :update, params: { id: 8, basket: @attrs }
          expect(assigns(:basket).checkouts.order('created_at DESC').first.item.circulation_status.name).to eq 'On Loan'
          expect(response).to redirect_to(checkouts_url(user_id: assigns(:basket).user.username))
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @basket = FactoryBot.create(:basket)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should destroy basket without user_id' do
        delete :destroy, params: { id: @basket.id, basket: { user_id: nil }, user_id: users(:user1).username }
        expect(response).to redirect_to(checkouts_url(user_id: assigns(:basket).user.username))
      end

      it 'should destroy basket' do
        delete :destroy, params: { id: @basket.id, basket: {}, user_id: users(:user1).username }
        expect(response).to redirect_to(checkouts_url(user_id: assigns(:basket).user.username))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should destroy basket without user_id' do
        delete :destroy, params: { id: @basket.id, basket: { user_id: nil }, user_id: users(:user1).username }
        expect(response).to redirect_to(checkouts_url(user_id: assigns(:basket).user.username))
      end

      it 'should destroy basket' do
        delete :destroy, params: { id: @basket.id, basket: {}, user_id: users(:user1).username }
        expect(response).to redirect_to(checkouts_url(user_id: assigns(:basket).user.username))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not destroy basket' do
        delete :destroy, params: { id: 3, user_id: users(:user1).username }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested basket' do
        delete :destroy, params: { id: @basket.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @basket.id }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end
end
