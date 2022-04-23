require 'rails_helper'

describe ReservesController do
  fixtures :all

  describe 'GET index', solr: true do
    before do
      Reserve.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all reserves as @reserves' do
        get :index
        assigns(:reserves).should eq(Reserve.order('reserves.id DESC').includes(:manifestation).page(1))
      end

      it "should get other user's reservation" do
        get :index, params: { user_id: users(:user1).username }
        response.should be_successful
        assigns(:reserves).should eq(users(:user1).reserves.order('reserves.id DESC').includes(:manifestation).page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all reserves as @reserves' do
        get :index
        assigns(:reserves).should eq(Reserve.order('reserves.id DESC').includes(:manifestation).page(1))
      end

      it 'should get index feed without user_id' do
        get :index, format: 'rss'
        response.should be_successful
        assigns(:reserves).count.should eq assigns(:reserves).total_entries
        assigns(:reserves).should eq(Reserve.order('reserves.id DESC').includes(:manifestation))
      end

      it 'should get index text without user_id' do
        get :index, format: :text
        response.should be_successful
        assigns(:reserves).count.should eq assigns(:reserves).total_entries
        assigns(:reserves).should eq(Reserve.order('reserves.id DESC').includes(:manifestation))
      end

      it 'should get index feed with user_id' do
        get :index, params: { user_id: users(:user1).username, format: 'rss' }
        response.should be_successful
        assigns(:reserves).should eq(users(:user1).reserves.order('reserves.id DESC').includes(:manifestation).page(1))
      end

      it 'should get index text with user_id' do
        get :index, params: { user_id: users(:user1).username, format: :text }
        response.should be_successful
        assigns(:reserves).should eq(users(:user1).reserves.order('reserves.id DESC').includes(:manifestation))
      end

      it "should get other user's index" do
        get :index, params: { user_id: users(:user1).username }
        response.should be_successful
        assigns(:reserves).should eq(users(:user1).reserves.order('reserves.id DESC').includes(:manifestation).page(1))
      end

      it "should get other user's index feed" do
        get :index, params: { user_id: users(:user1).username, format: :rss }
        response.should be_successful
        assigns(:reserves).should eq(users(:user1).reserves.order('reserves.id DESC').includes(:manifestation).page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns my reserves as @reserves' do
        get :index
        assigns(:reserves).should eq(users(:user1).reserves.order('reserves.id DESC').includes(:manifestation).page(1))
      end

      it 'should be redirected to my index' do
        get :index
        response.should be_successful
      end

      it 'should get my index feed' do
        get :index, format: :rss
        response.should be_successful
        response.should render_template('index')
      end

      it 'should get my index text' do
        get :index, format: :text
        response.should be_successful
        response.should render_template('index')
      end

      describe 'When my user_id is specified' do
        it 'should redirect to my reservation' do
          get :index, params: { user_id: users(:user1).username }
          response.should redirect_to reserves_url
        end

        it 'should redirect to my reservation feed' do
          get :index, params: { user_id: users(:user1).username, format: 'rss' }
          response.should redirect_to reserves_url(format: :rss)
        end

        it 'should redirect to my reservation text' do
          get :index, params: { user_id: users(:user1).username, format: :text }
          response.should redirect_to reserves_url(format: :text)
        end
      end

      describe 'When other user_id is specified' do
        before(:each) do
          @user = users(:user3)
        end

        it 'should not get any reserve as @reserves' do
          get :index, params: { user_id: @user.username }
          response.should be_forbidden
        end
      end

      it "should not get other user's index" do
        get :index, params: { user_id: users(:user2).username }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @reserves' do
        get :index
        assigns(:reserves).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :show, params: { id: reserve.id }
        assigns(:reserve).should eq(reserve)
      end

      it "should show other user's reservation" do
        get :show, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :show, params: { id: reserve.id }
        assigns(:reserve).should eq(reserve)
      end

      it "should show other user's reservation" do
        get :show, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :show, params: { id: reserve.id }
        assigns(:reserve).should eq(reserve)
      end

      it 'should show my reservation' do
        get :show, params: { id: 3 }
        response.should be_successful
      end

      it "should not show other user's reservation" do
        get :show, params: { id: 5 }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      before(:each) do
        @reserve = FactoryBot.create(:reserve)
      end

      it 'assigns the requested reserve as @reserve' do
        get :show, params: { id: @reserve.id }
        assigns(:reserve).should eq(@reserve)
      end

      it 'should be redirected to new_user_session_url' do
        get :show, params: { id: @reserve.id }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested reserve as @reserve' do
        get :new
        assigns(:reserve).should_not be_valid
      end

      it "should get other user's reservation" do
        get :new, params: { user_id: users(:user1).username, manifestation_id: 3 }
        assigns(:reserve).user.should eq users(:user1)
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested reserve as @reserve' do
        get :new
        assigns(:reserve).should_not be_valid
      end

      it 'should get new template without user_id' do
        get :new, params: { manifestation_id: 3 }
        response.should be_successful
      end

      it "should get other user's reservation" do
        get :new, params: { user_id: users(:user1).username, manifestation_id: 3 }
        assigns(:reserve).user.should eq users(:user1)
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested reserve as @reserve' do
        get :new
        assigns(:reserve).should_not be_valid
        response.should be_successful
      end

      it 'should get my new reservation' do
        get :new, params: { manifestation_id: 3 }
        response.should be_successful
      end

      it "should not get other user's new reservation" do
        get :new, params: { user_id: users(:user2).username, manifestation_id: 5 }
        response.should be_forbidden
      end

      it 'should not get new reservation when user_number is not set' do
        sign_in users(:user2)
        get :new, params: { user_id: users(:user2).username, manifestation_id: 3 }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested reserve as @reserve' do
        get :new
        assigns(:reserve).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :edit, params: { id: reserve.id }
        assigns(:reserve).should eq(reserve)
      end

      it "should edit other user's reservation" do
        get :edit, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :edit, params: { id: reserve.id }
        assigns(:reserve).should eq(reserve)
      end

      it 'should edit reserve without user_id' do
        get :edit, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :edit, params: { id: reserve.id }
        assigns(:reserve).should eq(reserve)
      end

      it 'should edit my reservation' do
        get :edit, params: { id: 3 }
        response.should be_successful
      end

      it "should not edit other user's reservation" do
        get :edit, params: { id: 5 }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested reserve as @reserve' do
        reserve = FactoryBot.create(:reserve)
        get :edit, params: { id: reserve.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = { user_number: users(:user1).profile.user_number, manifestation_id: 5 }
      @invalid_attrs = { user_number: users(:user1).profile.user_number, manifestation_id: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created reserve as @reserve' do
          post :create, params: { reserve: @attrs }
          assigns(:reserve).should be_valid
        end

        it 'redirects to the created reserve' do
          post :create, params: { reserve: @attrs }
          response.should redirect_to(assigns(:reserve))
          assigns(:reserve).expired_at.should be_nil
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved reserve as @reserve' do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).should_not be_valid
        end

        it 'redirects to the list' do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).expired_at.should be_nil
          response.should render_template('new')
          response.should be_successful
        end
      end

      it 'should not create reservation with past date' do
        post :create, params: { reserve: { user_number: users(:user1).profile.user_number, manifestation_id: 5, expired_at: '1901-01-01' } }
        assigns(:reserve).should_not be_valid
        response.should be_successful
      end

      it "should create other user's reserve" do
        post :create, params: { reserve: { user_number: users(:user1).profile.user_number, manifestation_id: 5 } }
        assigns(:reserve).expired_at.should be_nil
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it 'should not create reserve without manifestation_id' do
        post :create, params: { reserve: { user_number: users(:admin).profile.user_number } }
        response.should be_successful
      end

      it 'should not create reserve with missing user_number' do
        post :create, params: { reserve: { user_number: 'missing', manifestation_id: 5 } }
        response.should render_template('new')
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created reserve as @reserve' do
          post :create, params: { reserve: @attrs }
          assigns(:reserve).should be_valid
        end

        it 'redirects to the created reserve' do
          post :create, params: { reserve: @attrs }
          response.should redirect_to(assigns(:reserve))
          assigns(:reserve).expired_at.should be_nil
        end

        it 'should send accepted messages' do
          old_count = Message.count
          post :create, params: { reserve: @attrs }
          Message.count.should eq old_count + 2
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved reserve as @reserve' do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).expired_at.should be_nil
          response.should render_template('new')
          response.should be_successful
        end
      end

      it "should create other user's reserve" do
        post :create, params: { reserve: { user_number: users(:user1).profile.user_number, manifestation_id: 5 } }
        assigns(:reserve).should be_valid
        assigns(:reserve).expired_at.should be_nil
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it 'should not create reserve over reserve_limit' do
        post :create, params: { reserve: { user_number: users(:admin).profile.user_number, manifestation_id: 5 } }
        assigns(:reserve).errors[:base].include?(I18n.t('reserve.excessed_reservation_limit')).should be_truthy
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created reserve as @reserve' do
          post :create, params: { reserve: @attrs }
          assigns(:reserve).should be_valid
        end

        it 'redirects to the created reserve' do
          post :create, params: { reserve: @attrs }
          response.should redirect_to(assigns(:reserve))
          assigns(:reserve).expired_at.should be_nil
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved reserve as @reserve' do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).expired_at.should be_nil
          response.should render_template('new')
          response.should be_successful
        end
      end

      it "should not create other user's reservation" do
        post :create, params: { reserve: { user_number: users(:user2).profile.user_number, manifestation_id: 6 } }
        assigns(:reserve).expired_at.should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created reserve as @reserve' do
          post :create, params: { reserve: @attrs }
          assigns(:reserve).should be_nil
        end

        it 'redirects to the login page' do
          post :create, params: { reserve: @attrs }
          response.should redirect_to new_user_session_url
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved reserve as @reserve' do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).should be_nil
        end

        it 'redirects to the login page' do
          post :create, params: { reserve: @invalid_attrs }
          assigns(:reserve).should be_nil
          response.should redirect_to new_user_session_url
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @reserve = FactoryBot.create(:reserve)
      @attrs = FactoryBot.attributes_for(:reserve)
      @invalid_attrs = { manifestation_id: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
        end

        it 'assigns the requested reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
          assigns(:reserve).should eq(@reserve)
          response.should redirect_to(assigns(:reserve))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @reserve.id, reserve: @invalid_attrs }
          response.should render_template('edit')
        end
      end

      it 'should not update reserve without manifestation_id' do
        put :update, params: { id: 1, reserve: { user_number: users(:admin).profile.user_number, manifestation_id: nil } }
        assigns(:reserve).should_not be_valid
        response.should be_successful
      end

      it "should update other user's reservation without user_id" do
        put :update, params: { id: 3, reserve: { user_number: users(:user1).profile.user_number } }
        assigns(:reserve).should be_valid
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it 'should not update retained reservations if item_identifier is invalid' do
        put :update, params: { id: 14, reserve: { item_identifier: 'invalid' } }
        assigns(:reserve).should_not be_valid
        response.should be_successful
      end

      it 'should not update retained reservations if force_retaining is disabled' do
        put :update, params: { id: 15, reserve: { item_identifier: '00021' } }
        assigns(:reserve).should_not be_valid
        response.should be_successful
        assigns(:reserve).current_state.should eq 'requested'
        reserves(:reserve_00014).current_state.should eq 'retained'
      end

      it 'should update retained reservations if force_retaining is enabled' do
        put :update, params: { id: 15, reserve: { item_identifier: '00021', force_retaining: '1' } }
        assigns(:reserve).should be_valid
        assigns(:reserve).current_state.should eq 'retained'
        response.should redirect_to reserve_url(assigns(:reserve))
        reserves(:reserve_00014).current_state.should eq 'postponed'
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
        end

        it 'assigns the requested reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
          assigns(:reserve).should eq(@reserve)
          response.should redirect_to(assigns(:reserve))
        end
      end

      describe 'with invalid params' do
        it 'assigns the reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @invalid_attrs }
          assigns(:reserve).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @reserve.id, reserve: @invalid_attrs }
          response.should render_template('edit')
        end
      end

      it "should cancel other user's reservation" do
        put :update, params: { id: 3, reserve: { user_number: users(:user1).profile.user_number }, mode: 'cancel' }
        flash[:notice].should eq I18n.t('reserve.reservation_was_canceled')
        assigns(:reserve).current_state.should eq 'canceled'
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it 'should update reserve without user_id' do
        put :update, params: { id: 3, reserve: { user_number: users(:user1).profile.user_number } }
        assigns(:reserve).should be_valid
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it "should update other user's reservation" do
        put :update, params: { id: 3, reserve: { user_number: users(:user1).profile.user_number } }
        assigns(:reserve).should be_valid
        response.should redirect_to reserve_url(assigns(:reserve))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
        end

        it 'assigns the requested reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
          assigns(:reserve).should eq(@reserve)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @invalid_attrs }
          response.should be_forbidden
        end
      end

      it 'should cancel my reservation' do
        put :update, params: { id: 3, mode: 'cancel' }
        flash[:notice].should eq I18n.t('reserve.reservation_was_canceled')
        assigns(:reserve).current_state.should eq 'canceled'
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it 'should update my reservation' do
        put :update, params: { id: 3, reserve: { user_number: users(:user1).profile.user_number } }
        flash[:notice].should eq I18n.t('controller.successfully_updated', model: I18n.t('activerecord.models.reserve'))
        response.should redirect_to reserve_url(assigns(:reserve))
      end

      it "should not update other user's reservation" do
        put :update, params: { id: 5, reserve: { user_number: users(:user2).profile.user_number } }
        response.should be_forbidden
      end

      it "should not cancel other user's reservation" do
        put :update, params: { id: 5, reserve: { user_number: users(:user1).profile.user_number }, mode: 'cancel' }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested reserve' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @reserve.id, reserve: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested reserve as @reserve' do
          put :update, params: { id: @reserve.id, reserve: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @reserve = FactoryBot.create(:reserve)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested reserve' do
        delete :destroy, params: { id: @reserve.id }
      end

      it 'redirects to the reserves list' do
        delete :destroy, params: { id: @reserve.id }
        response.should redirect_to(reserves_url)
      end

      it "should destroy other user's reservation" do
        delete :destroy, params: { id: 3 }
        response.should redirect_to reserves_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested reserve' do
        delete :destroy, params: { id: @reserve.id }
      end

      it 'redirects to the reserves list' do
        delete :destroy, params: { id: @reserve.id }
        response.should redirect_to(reserves_url)
      end

      it "should destroy other user's reservation" do
        delete :destroy, params: { id: 3 }
        response.should redirect_to reserves_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested reserve' do
        delete :destroy, params: { id: @reserve.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @reserve.id }
        response.should be_forbidden
      end

      it 'should destroy my reservation' do
        delete :destroy, params: { id: 3 }
        response.should redirect_to reserves_url
      end

      it "should not destroy other user's reservation" do
        delete :destroy, params: { id: 5 }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested reserve' do
        delete :destroy, params: { id: @reserve.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @reserve.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
