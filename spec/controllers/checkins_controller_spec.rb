require 'rails_helper'

describe CheckinsController do
  fixtures :all

  def mock_user(stubs = {})
    (@mock_user ||= mock_model(Checkin).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all checkins as @checkins' do
        get :index
        expect(assigns(:checkins)).to eq Checkin.page(1)
        expect(response).to be_successful
      end

      describe 'When basket_id is specified' do
        it 'assigns all checkins as @checkins' do
          get :index, params: { basket_id: 10 }
          expect(assigns(:checkins)).to eq Basket.find(10).checkins.page(1)
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all checkins as @checkins' do
        get :index
        expect(assigns(:checkins)).to eq Checkin.page(1)
        expect(response).to be_successful
      end

      describe 'When basket_id is specified' do
        it 'assigns all checkins as @checkins' do
          get :index, params: { basket_id: 9 }
          expect(assigns(:checkins)).to eq Basket.find(9).checkins.page(1)
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign all checkins as @checkins' do
        get :index
        expect(assigns(:checkins)).to be_nil
        expect(response).to be_forbidden
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :show, params: { id: checkin.id }
        expect(assigns(:checkin)).to eq(checkin)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :show, params: { id: checkin.id }
        expect(assigns(:checkin)).to eq(checkin)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :show, params: { id: checkin.id }
        expect(assigns(:checkin)).to eq(checkin)
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :show, params: { id: checkin.id }
        expect(assigns(:checkin)).to eq(checkin)
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested checkin as @checkin' do
        get :new
        expect(assigns(:checkin)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested checkin as @checkin' do
        get :new
        expect(assigns(:checkin)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested checkin as @checkin' do
        get :new
        expect(assigns(:checkin)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested checkin as @checkin' do
        get :new
        expect(assigns(:checkin)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :edit, params: { id: checkin.id }
        expect(assigns(:checkin)).to eq(checkin)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :edit, params: { id: checkin.id }
        expect(assigns(:checkin)).to eq(checkin)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :edit, params: { id: checkin.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested checkin as @checkin' do
        checkin = checkins(:checkin_00001)
        get :edit, params: { id: checkin.id }
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
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should not create checkin without basket_id' do
          post :create, params: { checkin: @attrs }
          expect(response).to be_forbidden
        end

        describe 'When basket_id is specified' do
          it 'redirects to the created checkin' do
            post :create, params: { checkin: @attrs, basket_id: 9 }
            expect(response).to redirect_to(checkins_url(basket_id: assigns(:checkin).basket_id))
            expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          end

          it 'should checkin the overdue item' do
            post :create, params: { checkin: { item_identifier: '00014' }, basket_id: 9 }
            expect(response).to redirect_to(checkins_url(basket_id: assigns(:checkin).basket_id))
            expect(assigns(:checkin).checkout).to be_valid
            expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          end
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved checkin as @checkin' do
          post :create, params: { checkin: @invalid_attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { checkin: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end

      it 'should not create checkin without item_id' do
        post :create, params: { checkin: { item_identifier: nil }, basket_id: 9 }
        expect(assigns(:checkin)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should not create checkin without basket_id' do
          post :create, params: { checkin: @attrs }
          expect(response).to be_forbidden
        end

        it 'should show notification when it is reserved' do
          post :create, params: { checkin: { item_identifier: '00008' }, basket_id: 9 }
          expect(flash[:message].to_s.index(I18n.t('item.this_item_is_reserved'))).to be_truthy
          expect(assigns(:checkin).checkout.item).to be_retained
          expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          expect(response).to redirect_to(checkins_url(basket_id: assigns(:basket).id))
        end

        it 'should show notification when an item includes supplements' do
          post :create, params: { checkin: { item_identifier: '00004' }, basket_id: 9 }
          expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          expect(flash[:message].to_s.index(I18n.t('item.this_item_include_supplement'))).to be_truthy
          expect(response).to redirect_to(checkins_url(basket_id: assigns(:basket).id))
        end
      end

      it "should show notice when other library's item is checked in" do
        sign_in users(:librarian2)
        post :create, params: { checkin: { item_identifier: '00009' }, basket_id: 9 }
        expect(assigns(:checkin)).to be_valid
        expect(flash[:message].to_s.index(I18n.t('checkin.other_library_item'))).to be_truthy
        expect(response).to redirect_to(checkins_url(basket_id: assigns(:basket).id))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { checkin: @attrs }
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
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
        end

        it 'should redirect to new session url' do
          post :create, params: { checkin: @attrs }
          expect(response).to redirect_to new_user_session_url
        end
      end
    end
  end

  describe 'POST create (json format)' do
    before(:each) do
      @attrs = { item_identifier: '00003' }
      @invalid_attrs = { item_identifier: 'invalid' }
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should not create checkin without basket_id' do
          post :create, params: { checkin: @attrs }
          json = JSON.parse(response.body)
          expect(json['error']).to eq('forbidden')
        end

        describe 'When basket_id is specified' do
          it 'redirects to the created checkin' do
            post :create, params: { checkin: @attrs, basket_id: 9 }
            expect(response).to have_http_status(:created)
            json = JSON.parse(response.body)
            expect(json['result']['basket_id']).to eq(9)
            expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          end

          it 'should checkin the overdue item' do
            post :create, params: { checkin: { item_identifier: '00014' }, basket_id: 9 }
            expect(response).to have_http_status(:created)
            expect(assigns(:checkin).checkout).to be_valid
            expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          end
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved checkin as @checkin' do
          post :create, params: { checkin: @invalid_attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { checkin: @invalid_attrs }
          json = JSON.parse(response.body)
          expect(json['error']).to eq('forbidden')
        end
      end

      it 'should not create checkin without item_id' do
        post :create, params: { checkin: { item_identifier: nil }, basket_id: 9 }
        expect(assigns(:checkin)).not_to be_valid
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['messages']['base']).to match_array([ I18n.t('checkin.item_not_found') ])
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
          expect(assigns(:checkin)).to be_nil
        end

        it 'should not create checkin without basket_id' do
          post :create, params: { checkin: @attrs }
          json = JSON.parse(response.body)
          expect(json['error']).to eq('forbidden')
        end

        it 'should show notification when it is reserved' do
          post :create, params: { checkin: { item_identifier: '00008' }, basket_id: 9 }
          expect(flash[:message].to_s.index(I18n.t('item.this_item_is_reserved'))).to be_truthy
          expect(assigns(:checkin).checkout.item).to be_retained
          expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          expect(response).to have_http_status(:created)
        end

        it 'should show notification when an item includes supplements' do
          post :create, params: { checkin: { item_identifier: '00004' }, basket_id: 9 }
          expect(assigns(:checkin).checkout.item.circulation_status.name).to eq 'Available On Shelf'
          expect(flash[:message].to_s.index(I18n.t('item.this_item_include_supplement'))).to be_truthy
          expect(response).to have_http_status(:created)
        end
      end

      it "should show notice when other library's item is checked in" do
        sign_in users(:librarian2)
        post :create, params: { checkin: { item_identifier: '00009' }, basket_id: 9 }
        expect(assigns(:checkin)).to be_valid
        expect(flash[:message].to_s.index(I18n.t('checkin.other_library_item'))).to be_truthy
        expect(response).to have_http_status(:created)
      end
    end

    describe 'When not logged in' do
      before(:each) do
        @attrs = { item_identifier: '00003' }
        @invalid_attrs = { item_identifier: 'invalid' }
      end

      describe 'with valid params' do
        it 'assigns a newly created checkin as @checkin' do
          post :create, params: { checkin: @attrs }
        end

        it 'should redirect to new session url' do
          post :create, params: { checkin: @attrs }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @checkin = checkins(:checkin_00001)
      @attrs = { item_identifier: @checkin.item.item_identifier }
      @invalid_attrs = { item_identifier: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
        end

        it 'assigns the requested checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
          expect(assigns(:checkin)).to eq(@checkin)
          expect(response).to redirect_to(@checkin)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @checkin.id, checkin: @invalid_attrs }
          expect(response).to be_successful
        end

        it 'should not update checkin without item_identifier' do
          put :update, params: { id: @checkin.id, checkin: @attrs.merge(item_identifier: nil) }
          expect(assigns(:checkin)).to be_valid
          expect(response).to redirect_to(@checkin)
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
        end

        it 'assigns the requested checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
          expect(assigns(:checkin)).to eq(@checkin)
          expect(response).to redirect_to(@checkin)
        end
      end

      describe 'with invalid params' do
        it 'assigns the checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @invalid_attrs }
          expect(assigns(:checkin)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @checkin.id, checkin: @invalid_attrs }
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
        end

        it 'assigns the requested checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
          expect(assigns(:checkin)).to eq(@checkin)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested checkin' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @checkin.id, checkin: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested checkin as @checkin' do
          put :update, params: { id: @checkin.id, checkin: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @checkin = checkins(:checkin_00001)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested checkin' do
        delete :destroy, params: { id: @checkin.id }
      end

      it 'redirects to the checkins list' do
        delete :destroy, params: { id: @checkin.id }
        expect(response).to redirect_to(checkins_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested checkin' do
        delete :destroy, params: { id: @checkin.id }
      end

      it 'redirects to the checkins list' do
        delete :destroy, params: { id: @checkin.id }
        expect(response).to redirect_to(checkins_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested checkin' do
        delete :destroy, params: { id: @checkin.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @checkin.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested checkin' do
        delete :destroy, params: { id: @checkin.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @checkin.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
