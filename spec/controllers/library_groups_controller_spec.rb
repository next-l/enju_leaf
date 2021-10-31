require 'rails_helper'

describe LibraryGroupsController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all library_groups as @library_groups' do
        get :index
        assigns(:library_groups).should_not be_empty
      end
    end

    describe 'When not logged in' do
      it 'assigns all library_groups as @library_groups' do
        get :index
        assigns(:library_groups).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested library_group as @library_group' do
        get :show, params: { id: 1 }
        assigns(:library_group).should eq(LibraryGroup.find(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested library_group as @library_group' do
        get :show, params: { id: 1 }
        assigns(:library_group).should eq(LibraryGroup.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested library_group as @library_group' do
        library_group = LibraryGroup.find(1)
        get :edit, params: { id: library_group.id }
        assigns(:library_group).should eq(library_group)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested library_group as @library_group' do
        library_group = LibraryGroup.find(1)
        get :edit, params: { id: library_group.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested library_group as @library_group' do
        library_group = LibraryGroup.find(1)
        get :edit, params: { id: library_group.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested library_group as @library_group' do
        library_group = LibraryGroup.find(1)
        get :edit, params: { id: library_group.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @library_group = LibraryGroup.find(1)
      @attrs = { name: 'example' }
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested library_group' do
          put :update, params: { id: @library_group.id, library_group: @attrs }
        end

        it 'assigns the requested library_group as @library_group' do
          put :update, params: { id: @library_group.id, library_group: @attrs }
          assigns(:library_group).should eq(@library_group)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested library_group as @library_group' do
          put :update, params: { id: @library_group.id, library_group: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested library_group' do
          put :update, params: { id: @library_group.id, library_group: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @library_group.id, library_group: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested library_group as @library_group' do
          put :update, params: { id: @library_group.id, library_group: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end
end
