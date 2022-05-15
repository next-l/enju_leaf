require 'rails_helper'

describe ItemsController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:item)
  end

  describe 'GET index', solr: true do
    before do
      Item.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all items as @items' do
        get :index
        expect(assigns(:items)).to_not be_nil
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all items as @items' do
        get :index
        expect(assigns(:items)).to_not be_nil
      end

      it 'assigns items as @items with acquired_from and acquired_until' do
        get :index, params: { acquired_from: '2015-09-20', acquired_until: '2015-09-26' }
        expect(assigns(:items)).to_not be_nil
        expect(assigns(:items).count).to eq 1
      end

      it 'assigns items as @items with acquired_from' do
        get :index, params: { acquired_from: '2015-09-20' }
        expect(assigns(:items)).to_not be_nil
        expect(assigns(:items).count).to eq 1
      end

      it 'assigns items as @items with acquired_until' do
        get :index, params: { acquired_until: '2015-09-20' }
        expect(assigns(:items)).to_not be_nil
        expect(assigns(:items).count).to eq 1
      end

      it 'accepts text format' do
        get :index, format: :text
        expect(assigns(:items)).to_not be_nil
      end

      describe 'in JSON response' do
        render_views
        it 'should not assign unnecessary attributes' do
          get :index, format: :json
          expect(response.body).to match /manifestation_id/
          expect(response.body).not_to match /price/
          expect(response.body).not_to match /memo/
          expect(response.body).not_to match /bookstore_id/
          expect(response.body).not_to match /budget_type_id/
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all items as @items' do
        get :index
        expect(assigns(:items)).to_not be_nil
      end

      describe 'in JSON response' do
        render_views
        it 'should not assign unnecessary attributes' do
          get :index, format: :json
          expect(response.body).to match /manifestation_id/
          expect(response.body).not_to match /price/
          expect(response.body).not_to match /memo/
          expect(response.body).not_to match /bookstore_id/
          expect(response.body).not_to match /budget_type_id/
        end
      end
    end

    describe 'When not logged in' do
      it 'assigns all items as @items' do
        get :index
        expect(assigns(:items)).to_not be_nil
      end

      it 'should get index with agent_id' do
        get :index, params: { agent_id: 1 }
        expect(response).to be_successful
        assigns(:agent).should eq Agent.find(1)
        expect(assigns(:items)).to eq assigns(:agent).items.order('created_at DESC').page(1)
      end

      it 'should get index with manifestation_id' do
        get :index, params: { manifestation_id: 1 }
        expect(response).to be_successful
        assigns(:manifestation).should eq Manifestation.find(1)
        assigns(:items).collect(&:id).should eq assigns(:manifestation).items.order('items.created_at DESC').page(1).pluck(:id)
      end

      it 'should get index with shelf_id' do
        get :index, params: { shelf_id: 1 }
        expect(response).to be_successful
        assigns(:shelf).should eq Shelf.find(1)
        expect(assigns(:items).collect(&:id)).to eq assigns(:shelf).items.order('created_at DESC').page(1).pluck(:id)
      end

      describe 'in JSON response' do
        render_views
        it 'should not assign unnecessary attributes' do
          get :index, format: :json
          expect(response.body).to match /manifestation_id/
          expect(response.body).not_to match /price/
          expect(response.body).not_to match /memo/
          expect(response.body).not_to match /bookstore_id/
          expect(response.body).not_to match /budget_type_id/
        end
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @item = FactoryBot.create(:item)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested item as @item' do
        get :show, params: { id: @item.id }
        expect(assigns(:item)).to eq(@item)
      end

      it 'should not show missing item' do
        lambda do
          get :show, params: { id: 'missing' }
        end.should raise_error(ActiveRecord::RecordNotFound)
        # expect(response).to be_missing
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested item as @item' do
        get :show, params: { id: @item.id }
        expect(assigns(:item)).to eq(@item)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested item as @item' do
        get :show, params: { id: @item.id }
        expect(assigns(:item)).to eq(@item)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested item as @item' do
        get :show, params: { id: @item.id }
        expect(assigns(:item)).to eq(@item)
      end
    end
  end

  describe 'GET new' do
    before(:each) do
      @manifestation = FactoryBot.create(:manifestation)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested item as @item' do
        get :new, params: { manifestation_id: @manifestation.id }
        expect(assigns(:item)).to be_valid
        expect(response).to be_successful
      end

      it 'should not get new without manifestation_id' do
        get :new
        expect(response).to redirect_to(manifestations_url)
      end

      it 'should work without exception, even if library and shelf is unavailable' do
        Library.real.each do |library|
          library.try(:shelves).to_a.each(&:destroy)
          library.delete
        end
        get :new, params: { manifestation_id: @manifestation.id }
        expect(response).to redirect_to(libraries_url)
      end

      it 'should not get new item for series_master' do
        manifestation_serial = FactoryBot.create(:manifestation_serial)
        get :new, params: { manifestation_id: manifestation_serial.id }
        expect(response).to redirect_to(manifestations_url(parent_id: manifestation_serial.id))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested item as @item' do
        get :new, params: { manifestation_id: @manifestation.id }
        expect(assigns(:item)).to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested item as @item' do
        get :new, params: { manifestation_id: @manifestation.id }
        expect(assigns(:item)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested item as @item' do
        get :new, params: { manifestation_id: @manifestation.id }
        expect(assigns(:item)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested item as @item' do
        item = FactoryBot.create(:item)
        get :edit, params: { id: item.id }
        expect(assigns(:item)).to eq(item)
      end

      it 'should not edit missing item' do
        lambda do
          get :edit, params: { id: 'missing' }
        end.should raise_error(ActiveRecord::RecordNotFound)
        # expect(response).to be_missing
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested item as @item' do
        item = FactoryBot.create(:item)
        get :edit, params: { id: item.id }
        expect(assigns(:item)).to eq(item)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested item as @item' do
        item = FactoryBot.create(:item)
        get :edit, params: { id: item.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested item as @item' do
        item = FactoryBot.create(:item)
        get :edit, params: { id: item.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      manifestation = FactoryBot.create(:manifestation)
      @attrs = FactoryBot.attributes_for(:item, manifestation_id: manifestation.id)
      @invalid_attrs = { item_identifier: '無効なID', manifestation_id: manifestation.id }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created item as @item' do
          post :create, params: { item: @attrs }
          expect(assigns(:item)).to be_valid
        end

        it 'redirects to the created item' do
          post :create, params: { item: @attrs }
          assigns(:item).manifestation.should_not be_nil
          expect(response).to redirect_to(item_url(assigns(:item)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item as @item' do
          post :create, params: { item: @invalid_attrs }
          expect(assigns(:item)).to_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { item: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end

      it 'should not create item without manifestation_id' do
        lambda do
          post :create, params: { item: { circulation_status_id: 1 } }
        end.should raise_error(ActiveRecord::RecordNotFound)
        expect(assigns(:item)).to_not be_valid
        # expect(response).to be_missing
      end

      it 'should not create item already created' do
        post :create, params: { item: { circulation_status_id: 1, item_identifier: '00001', manifestation_id: 1 } }
        expect(assigns(:item)).to_not be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created item as @item' do
          post :create, params: { item: @attrs }
          expect(assigns(:item)).to be_valid
        end

        it 'redirects to the created item' do
          post :create, params: { item: @attrs }
          expect(response).to redirect_to(item_url(assigns(:item)))
        end

        it 'accepts custom values' do
          post :create, params: { item: @attrs.merge(item_custom_values_attributes: Array.new(3){FactoryBot.attributes_for(:item_custom_value, item_custom_property_id: FactoryBot.create(:item_custom_property).id)}) }
          expect(assigns(:item)).to be_valid
          expect(assigns(:item).item_custom_values.count).to eq 3
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item as @item' do
          post :create, params: { item: @invalid_attrs }
          expect(assigns(:item)).to_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { item: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created item as @item' do
          post :create, params: { item: @attrs }
          expect(assigns(:item)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item as @item' do
          post :create, params: { item: @invalid_attrs }
          expect(assigns(:item)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created item as @item' do
          post :create, params: { item: @attrs }
          expect(assigns(:item)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item as @item' do
          post :create, params: { item: @invalid_attrs }
          expect(assigns(:item)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @item = FactoryBot.create(:item)
      @attrs = FactoryBot.attributes_for(:item)
      @invalid_attrs = { item_identifier: '無効なID' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested item' do
          put :update, params: { id: @item.id, item: @attrs }
        end

        it 'assigns the requested item as @item' do
          put :update, params: { id: @item.id, item: @attrs }
          expect(assigns(:item)).to eq(@item)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item as @item' do
          put :update, params: { id: @item.id, item: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @item, item: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested item' do
          put :update, params: { id: @item.id, item: @attrs }
        end

        it 'assigns the requested item as @item' do
          put :update, params: { id: @item.id, item: @attrs }
          expect(assigns(:item)).to eq(@item)
          expect(response).to redirect_to(@item)
        end

        it 'accepts custom values' do
          @item.item_custom_values << FactoryBot.build(:item_custom_value)
          put :update, params: { id: @item.id, item: @attrs.merge(item_custom_values_attributes: [{id: @item.item_custom_values.first.id, value: 'test'}]) }
          expect(assigns(:item)).to be_valid
          expect(assigns(:item).item_custom_values.count).to eq 1
          expect(assigns(:item).item_custom_values.first.value).to eq 'test'
        end

        it 'accepts custom values when the value is empty' do
          @item.item_custom_values << FactoryBot.build(:item_custom_value)
          put :update, params: { id: @item.id, item: @attrs.merge(item_custom_values_attributes: [{id: @item.item_custom_values.first.id, value: ''}]) }
          expect(assigns(:item)).to be_valid
          expect(assigns(:item).item_custom_values.count).to eq 1
          expect(assigns(:item).item_custom_values.first.value).to eq ''
        end
      end

      describe 'with invalid params' do
        it 'assigns the item as @item' do
          put :update, params: { id: @item, item: @invalid_attrs }
          expect(assigns(:item)).to_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @item, item: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested item' do
          put :update, params: { id: @item.id, item: @attrs }
        end

        it 'assigns the requested item as @item' do
          put :update, params: { id: @item.id, item: @attrs }
          expect(assigns(:item)).to eq(@item)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item as @item' do
          put :update, params: { id: @item.id, item: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested item' do
          put :update, params: { id: @item.id, item: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @item.id, item: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item as @item' do
          put :update, params: { id: @item.id, item: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @item = FactoryBot.create(:item)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested item' do
        delete :destroy, params: { id: @item.id }
      end

      it 'redirects to the items list' do
        manifestation = @item.manifestation
        delete :destroy, params: { id: @item.id }
        expect(response).to redirect_to(items_url(manifestation_id: manifestation.id))
      end

      it 'should not destroy missing item' do
        lambda do
          delete :destroy, params: { id: 'missing' }
        end.should raise_error(ActiveRecord::RecordNotFound)
        # expect(response).to be_missing
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested item' do
        delete :destroy, params: { id: @item.id }
      end

      it 'redirects to the items list' do
        manifestation = @item.manifestation
        delete :destroy, params: { id: @item.id }
        expect(response).to redirect_to(items_url(manifestation_id: manifestation.id))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested item' do
        delete :destroy, params: { id: @item.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @item.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested item' do
        delete :destroy, params: { id: @item.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @item.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
