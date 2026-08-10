require 'rails_helper'

describe AcceptsController do
  fixtures :all

  def mock_user(stubs = {})
    (@mock_user ||= mock_model(Accept).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all accepts as @accepts' do
        get :index
        expect(assigns(:accepts)).to be_truthy
        expect(response).to be_successful
      end

      describe 'When basket_id is specified' do
        it 'assigns all accepts as @accepts' do
          get :index, params: { basket_id: 10 }
          expect(assigns(:accepts)).to eq baskets(:basket_00010).accepts.order('accepts.created_at DESC').page(1)
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all accepts as @accepts' do
        get :index
        expect(assigns(:accepts)).not_to be_nil
        expect(response).to be_successful
      end

      describe 'When basket_id is specified' do
        it 'assigns all accepts as @accepts' do
          get :index, params: { basket_id: 9 }
          expect(assigns(:accepts)).to eq baskets(:basket_00009).accepts.order('accepts.created_at DESC').page(1)
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign all accepts as @accepts' do
        get :index
        expect(assigns(:accepts)).to be_nil
        expect(response).to be_forbidden
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested accept as @accept' do
        accept = FactoryBot.create(:accept)
        get :show, params: { id: accept.id }
        expect(assigns(:accept)).to eq(accept)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested accept as @accept' do
        accept = FactoryBot.create(:accept)
        get :show, params: { id: accept.id }
        expect(assigns(:accept)).to eq(accept)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested accept as @accept' do
        accept = FactoryBot.create(:accept)
        get :show, params: { id: accept.id }
        expect(assigns(:accept)).to eq(accept)
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested accept as @accept' do
        accept = FactoryBot.create(:accept)
        get :show, params: { id: accept.id }
        expect(assigns(:accept)).to eq(accept)
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested accept as @accept' do
        get :new
        expect(assigns(:accept)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested accept as @accept' do
        get :new
        expect(assigns(:accept)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested accept as @accept' do
        get :new
        expect(assigns(:accept)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested accept as @accept' do
        get :new
        expect(assigns(:accept)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = { item_identifier: '00003' }
      @invalid_attrs = { item_identifier: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created accept as @accept' do
          post :create, params: { accept: @attrs }
          expect(assigns(:accept)).to be_nil
        end

        it 'should not create a new accept without basket_id' do
          post :create, params: { accept: @attrs }
          expect(response).to be_forbidden
        end

        describe 'When basket_id is specified' do
          it 'redirects to the created accept' do
            post :create, params: { accept: @attrs, basket_id: 9 }
            expect(response).to redirect_to(accepts_url(basket_id: assigns(:accept).basket.id))
            expect(assigns(:accept).item.circulation_status.name).to eq 'Available On Shelf'
          end
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved accept as @accept' do
          post :create, params: { accept: @invalid_attrs }
          expect(assigns(:accept)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { accept: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end

      it 'should not create accept without item_id' do
        post :create, params: { accept: { item_identifier: nil }, basket_id: 9 }
        expect(assigns(:accept)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created accept as @accept' do
          post :create, params: { accept: @attrs }
          expect(assigns(:accept)).to be_nil
        end

        it 'should not create a new accept without basket_id' do
          post :create, params: { accept: @attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created accept as @accept' do
          post :create, params: { accept: @attrs }
          expect(assigns(:accept)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { accept: @attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      before(:each) do
        @attrs = { item_identifier: '00003' }
        @invalid_attrs = { item_identifier: 'invalid' }
      end

      describe 'with valid params' do
        it 'assigns a newly created accept as @accept' do
          post :create, params: { accept: @attrs }
        end

        it 'should redirect to new session url' do
          post :create, params: { accept: @attrs }
          expect(response).to redirect_to new_user_session_url
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @accept = FactoryBot.create(:accept)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested accept' do
        delete :destroy, params: { id: @accept.id }
      end

      it 'redirects to the accepts list' do
        delete :destroy, params: { id: @accept.id }
        expect(response).to redirect_to(accepts_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested accept' do
        delete :destroy, params: { id: @accept.id }
      end

      it 'redirects to the accepts list' do
        delete :destroy, params: { id: @accept.id }
        expect(response).to redirect_to(accepts_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested accept' do
        delete :destroy, params: { id: @accept.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @accept.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested accept' do
        delete :destroy, params: { id: @accept.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @accept.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
