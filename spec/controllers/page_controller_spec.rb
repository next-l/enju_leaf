require 'rails_helper'

describe PageController do
  fixtures :users, :manifestations, :items
  fixtures :all

  describe 'GET page' do
    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should get import' do
        get :import
        expect(response).to be_successful
      end

      it 'should get configuration' do
        get :configuration
        expect(response).to be_successful
      end

      it 'should get system information' do
        get :system_information
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should redirect to user' do
        get :index
        expect(response).to be_successful
      end

      it 'should not get import' do
        get :import
        expect(response).to be_forbidden
      end

      it 'should not get configuration' do
        get :configuration
        expect(response).to be_forbidden
      end

      it 'should not get system information' do
        get :system_information
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should get index' do
        get :index
        expect(response).to be_successful
      end

      it 'should get opensearch' do
        get :opensearch, format: :xml
        expect(response).to be_successful
      end

      it 'should get msie_accelerator' do
        get :msie_accelerator, format: :xml
        expect(response).to be_successful
      end

      it 'should get routing_error' do
        get :routing_error
        expect(response).to be_not_found
        expect(response).to render_template('page/404')
      end

      it 'should get advanced_search' do
        get :advanced_search
        expect(response).to be_successful
        expect(assigns(:libraries)).to eq Library.order(:position)
      end

      it 'should get about' do
        get :about
        expect(response).to be_successful
      end

      it 'should get add_on' do
        get :add_on
        expect(response).to be_successful
      end

      it 'should get statistics' do
        get :statistics
        expect(response).to be_successful
      end

      it 'should not get import' do
        get :import
        expect(response).to redirect_to new_user_session_url
      end

      it 'should not get configuration' do
        get :configuration
        expect(response).to redirect_to new_user_session_url
      end

      it 'should not get system information' do
        get :system_information
        expect(response).to redirect_to new_user_session_url
      end
    end
  end
end
