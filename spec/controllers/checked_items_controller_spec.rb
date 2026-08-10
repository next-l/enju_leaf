require 'rails_helper'

describe CheckedItemsController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all checked_items as @checked_items' do
        get :index
        expect(assigns(:checked_items)).not_to be_empty
        expect(response).to be_successful
      end

      it 'should get index without basket_id' do
        get :index, params: { item_id: 1 }
        expect(assigns(:checked_items)).not_to be_empty
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should be forbidden' do
        get :index
        expect(assigns(:checked_items)).not_to be_empty
        expect(response).to be_successful
      end

      describe 'When basket is specified' do
        it 'assigns checked_items as @checked_items' do
          get :index, params: { basket_id: 1 }
          expect(assigns(:checked_items)).not_to be_empty
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns empty as @checked_items' do
        get :index
        expect(assigns(:checked_items)).to be_nil
        expect(response).to be_forbidden
      end

      it 'should not get index' do
        get :index, params: { basket_id: 3, item_id: 3 }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @checked_items' do
        get :index
        expect(assigns(:checked_items)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end

      it 'should not get index with basket_id and item_id' do
        get :index, params: { basket_id: 1, item_id: 1 }
        expect(assigns(:checked_items)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested checked_item as @checked_item' do
        get :show, params: { id: 1 }
        expect(assigns(:checked_item)).to eq(checked_items(:checked_item_00001))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested checked_item as @checked_item' do
        get :show, params: { id: 1 }
        expect(assigns(:checked_item)).to eq(checked_items(:checked_item_00001))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested checked_item as @checked_item' do
        get :show, params: { id: 1 }
        expect(assigns(:checked_item)).to eq(checked_items(:checked_item_00001))
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested checked_item as @checked_item' do
        get :show, params: { id: 1 }
        expect(assigns(:checked_item)).to eq(checked_items(:checked_item_00001))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested checked_item as @checked_item' do
        get :new, params: { basket_id: 3 }
        expect(assigns(:checked_item)).not_to be_valid
      end

      describe 'When basket is not specified' do
        it 'should be forbidden' do
          get :new
          expect(response).to redirect_to new_basket_url
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested checked_item as @checked_item' do
        get :new, params: { basket_id: 3 }
        expect(assigns(:checked_item)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested checked_item as @checked_item' do
        get :new, params: { basket_id: 3 }
        expect(assigns(:checked_item)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested checked_item as @checked_item' do
        get :new, params: { basket_id: 3 }
        expect(assigns(:checked_item)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested checked_item as @checked_item' do
        checked_item = checked_items(:checked_item_00001)
        get :edit, params: { id: checked_item.id }
        expect(assigns(:checked_item)).to eq(checked_item)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested checked_item as @checked_item' do
        checked_item = checked_items(:checked_item_00001)
        get :edit, params: { id: checked_item.id }
        expect(assigns(:checked_item)).to eq(checked_item)
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested checked_item as @checked_item' do
        checked_item = checked_items(:checked_item_00001)
        get :edit, params: { id: checked_item.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested checked_item as @checked_item' do
        checked_item = checked_items(:checked_item_00001)
        get :edit, params: { id: checked_item.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = { item_identifier: '00011' }
      @invalid_attrs = { item_identifier: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'When the item is missing' do
        it 'assigns a newly created checked_item as @checked_item' do
          post :create, params: { checked_item: { item_identifier: 'not found' }, basket_id: 1 }
          expect(assigns(:checked_item)).not_to be_valid
          expect(assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.item_not_found'))).to be_truthy
        end
      end

      describe 'When the item is not for checkout' do
        it 'assigns a newly created checked_item as @checked_item' do
          post :create, params: { checked_item: { item_identifier: '00017' }, basket_id: 1 }
          expect(assigns(:checked_item)).not_to be_valid
          expect(assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout'))).to be_truthy
        end
      end

      describe 'When the item is already checked out' do
        it 'assigns a newly created checked_item as @checked_item' do
          post :create, params: { checked_item: { item_identifier: '00013' }, basket_id: 8 }
          expect(assigns(:checked_item)).not_to be_valid
          expect(assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.already_checked_out'))).to be_truthy
        end
      end

      describe 'When the item is reserved' do
        it 'assigns a newly created checked_item as @checked_item' do
          old_count = items(:item_00021).manifestation.reserves.waiting.count
          post :create, params: { checked_item: { item_identifier: '00021' }, basket_id: 11 }
          expect(items(:item_00021).user_reservation(Basket.find(11).user)).to be_truthy
          expect(assigns(:checked_item)).not_to be_valid
          expect(assigns(:checked_item).errors[:base]).to include(I18n.t('activerecord.errors.messages.checked_item.reserved_item_included'))
          expect(assigns(:checked_item).item.manifestation.reserves.waiting.count).to eq old_count
          expect(assigns(:checked_item).librarian).to eq users(:admin)
        end
      end

      it 'should not create checked_item without basket_id' do
        post :create, params: { checked_item: { item_identifier: '00004' } }
        expect(response).to be_forbidden
      end

      it 'should not create checked_item without item_id' do
        post :create, params: { checked_item: { item_identifier: '00004' }, basket_id: 1 }
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should create checked_item' do
        post :create, params: { checked_item: @attrs, basket_id: 3 }
        expect(assigns(:checked_item).due_date.to_s).to eq Time.zone.now.tomorrow.end_of_day.to_s
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
      end

      it 'should create checked_item with item_identifier' do
        post :create, params: { checked_item: { item_identifier: '00011' }, basket_id: 3 }
        expect(assigns(:checked_item)).to be_truthy
        expect(assigns(:checked_item).due_date).not_to be_nil
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
      end

      it 'should override due_date' do
        post :create, params: { checked_item: { item_identifier: '00011', due_date_string: 1.year.from_now.strftime('%Y-%m-%d') }, basket_id: 3 }
        expect(assigns(:checked_item)).to be_truthy
        expect(assigns(:checked_item).due_date.to_s).to eq 1.year.from_now.end_of_day.to_s
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
      end

      it 'should not create checked_item with an invalid due_date' do
        post :create, params: { checked_item: { item_identifier: '00011', due_date_string: 'invalid' }, basket_id: 3 }
        expect(assigns(:checked_item)).not_to be_valid
        expect(assigns(:checked_item).due_date).to be_nil
        expect(response).to be_successful
      end

      it 'should not create checked_item if excessed checkout_limit' do
        post :create, params: { checked_item: { item_identifier: '00011' }, basket_id: 1 }
        expect(response).to be_successful
        expect(assigns(:checked_item).errors['base'].include?(I18n.t('activerecord.errors.messages.checked_item.excessed_checkout_limit'))).to be_truthy
      end

      it 'should show message when the item includes supplements' do
        post :create, params: { checked_item: { item_identifier: '00006' }, basket_id: 3 }
        expect(assigns(:checked_item).due_date).not_to be_nil
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
        expect(flash[:message].index(I18n.t('item.this_item_include_supplement'))).to be_truthy
      end

      it 'should create checked_item when ignore_restriction is checked' do
        post :create, params: { checked_item: { item_identifier: '00011', ignore_restriction: '1' }, basket_id: 2 }
        expect(assigns(:checked_item).due_date).not_to be_nil
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not create checked_item' do
        post :create, params: { checked_item: { item_identifier: '00004' }, basket_id: 3 }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in as' do
      it 'should not create checked_item' do
        post :create, params: { checked_item: { item_identifier: '00004' }, basket_id: 1 }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @attrs = { item_identifier: '00011' }
      @invalid_attrs = { item_identifier: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should not update checked_item without basket_id' do
        put :update, params: { id: 1, checked_item: {} }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not update checked_item without basket_id' do
        put :update, params: { id: 1, checked_item: {} }
        expect(response).to be_forbidden
      end

      it 'should update checked_item' do
        put :update, params: { id: 4, checked_item: {}, basket_id: 8 }
        expect(assigns(:checked_item)).to be_valid
        expect(response).to redirect_to checked_item_url(assigns(:checked_item))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not update checked_item' do
        put :update, params: { id: 1, checked_item: {}, basket_id: 3 }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not update checked_item' do
        put :update, params: { id: 1, checked_item: {}, basket_id: 1 }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'DELETE destroy' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should destroy checked_item' do
        delete :destroy, params: { id: 1 }
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should destroy checked_item' do
        delete :destroy, params: { id: 1 }
        expect(response).to redirect_to checked_items_url(basket_id: assigns(:checked_item).basket_id)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not destroy checked_item' do
        delete :destroy, params: { id: 3 }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not destroy checked_item' do
        delete :destroy, params: { id: 1 }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end
end
