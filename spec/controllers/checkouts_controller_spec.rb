require 'rails_helper'

describe CheckoutsController do
  fixtures :all

  describe 'GET index', solr: true do
    before do
      Checkout.reindex
    end

    before(:each) do
      FactoryBot.create(:profile)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all checkouts as @checkouts' do
        get :index
        assigns(:checkouts).should eq Checkout.order('checkouts.created_at DESC').page(1)
        assigns(:checkouts).total_entries.should eq Checkout.count
      end

      it "should get other user's index" do
        get :index, params: { user_id: users(:admin).username }
        response.should be_successful
        assigns(:checkouts).should eq users(:admin).checkouts.not_returned.order('checkouts.id DESC').page(1)
      end

      describe "with render_views" do
        render_views
        it "should accept params: user_id, days_overdue, and reserved" do
          username = users(:admin).username
          get :index, params: { user_id: username }
          expect(response.body).to have_link "No (3)", href: "/checkouts?reserved=false&user_id=#{username}"
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should get index' do
        get :index
        response.should be_successful
      end

      it 'should get index text' do
        get :index, format: :text
        assigns(:checkouts).count.should eq assigns(:checkouts).total_entries
        response.should be_successful
      end

      it 'should get index rss' do
        get :index, format: 'rss'
        assigns(:checkouts).count.should eq assigns(:checkouts).total_entries
        response.should be_successful
      end

      it 'should get overdue index' do
        get :index, params: { days_overdue: 1 }
        assigns(:checkouts).should eq Checkout.overdue(1.day.ago.beginning_of_day).order('checkouts.id DESC').page(1)
        response.should be_successful
      end

      it 'should get overdue index with number of days_overdue' do
        get :index, params: { days_overdue: 2 }
        response.should be_successful
        assigns(:checkouts).size.should > 0
      end

      it 'should get overdue index with invalid number of days_overdue' do
        get :index, params: { days_overdue: 'invalid days' }
        response.should be_successful
        assigns(:checkouts).size.should > 0
      end

      it "should get other user's index" do
        get :index, params: { user_id: users(:admin).username }
        response.should be_successful
        assigns(:checkouts).should eq users(:admin).checkouts.not_returned.order('checkouts.id DESC').page(1)
      end

      it 'should get index with item_id' do
        get :index, params: { item_id: 1 }
        response.should be_successful
        assigns(:checkouts).should eq items(:item_00001).checkouts.order('checkouts.id DESC').page(1)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all checkouts as @checkouts' do
        get :index
        assigns(:checkouts).should eq(users(:user1).checkouts.order('checkouts.created_at DESC').page(1))
        assigns(:checkouts).total_entries.should eq users(:user1).checkouts.count
        response.should be_successful
      end

      it "should be forbidden if other's username is specified" do
        user = users(:user3)
        get :index, params: { user_id: user.username }
        assigns(:checkouts).should be_nil
        response.should be_forbidden
      end

      it 'should get my index feed' do
        get :index, format: 'rss'
        response.should be_successful
        assigns(:checkouts).should eq(users(:user1).checkouts.order('checkouts.created_at DESC').page(1))
      end

      it 'should get my index with user_id' do
        get :index, params: { user_id: users(:user1).username }
        assigns(:checkouts).should be_nil
        response.should redirect_to checkouts_url
      end

      it 'should get my index in text format' do
        get :index, params: { user_id: users(:user1).username, format: :text }
        response.should redirect_to checkouts_url(format: :text)
        assigns(:checkouts).should be_nil
      end

      it 'should get my index in rss format' do
        get :index, params: { user_id: users(:user1).username, format: 'rss' }
        response.should redirect_to checkouts_url(format: :rss)
        assigns(:checkouts).should be_nil
      end

      it "should not get other user's index" do
        get :index, params: { user_id: users(:admin).username }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns nil as @checkouts' do
        get :index
        assigns(:checkouts).should be_nil
        response.should redirect_to(new_user_session_url)
      end

      it 'assigns his own checkouts as @checkouts' do
        token = '577830b08ecf9c4c4333d599a57a6f44a7fe76c0'
        user = Profile.where(checkout_icalendar_token: token).first.user
        get :index, params: { icalendar_token: token }
        assigns(:checkouts).should eq user.checkouts.not_returned.order('checkouts.id DESC')
        response.should be_successful
      end

      it 'should get ics template' do
        token = '577830b08ecf9c4c4333d599a57a6f44a7fe76c0'
        user = Profile.where(checkout_icalendar_token: token).first.user
        get :index, params: { icalendar_token: token, format: :ics }
        assigns(:checkouts).should eq user.checkouts.not_returned.order('checkouts.id DESC')
        response.should be_successful
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it "should show other user's content" do
        get :show, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it "should show other user's content" do
        get :show, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should show my account' do
        get :show, params: { id: 3 }
        response.should be_successful
        assigns(:checkout).should eq checkouts(:checkout_00003)
      end

      it "should not show other user's checkout" do
        get :show, params: { id: 1 }
        response.should be_forbidden
        assigns(:checkout).should eq checkouts(:checkout_00001)
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested checkout as @checkout' do
        get :show, params: { id: 1 }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it "should edit other user's checkout" do
        get :edit, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it "should edit other user's checkout" do
        get :edit, params: { id: 3 }
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should edit my checkout' do
        sign_in users(:user1)
        get :edit, params: { id: 3 }
        response.should be_successful
      end

      it "should not edit other user's checkout" do
        get :edit, params: { id: 1 }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not edit checkout' do
        get :edit, params: { id: 1 }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
      @attrs = { due_date: 1.day.from_now }
      @invalid_attrs = { item_identifier: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested checkout' do
          put :update, params: { id: @checkout.id, checkout: @attrs }
        end

        it 'assigns the requested checkout as @checkout' do
          old_due_date = @checkout.due_date
          put :update, params: { id: @checkout.id, checkout: @attrs }
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(assigns(:checkout))
          assigns(:checkout).due_date.to_s.should eq 1.day.from_now.end_of_day.to_s
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested checkout as @checkout' do
          put :update, params: { id: @checkout.id, checkout: @invalid_attrs }
        end

        it 'should ignore item_id' do
          put :update, params: { id: @checkout.id, checkout: @invalid_attrs }
          response.should redirect_to(assigns(:checkout))
          assigns(:checkout).changed?.should be_falsy
        end

        it 'should not accept invalid date' do
          put :update, params: { id: @checkout.id, checkout: @invalid_attrs.merge(due_date: '2017-03-151') }
          assigns(:checkout).changed?.should be_truthy
          response.should be_successful
        end
      end

      it 'should remove its own checkout history' do
        put :remove_all, params: { user_id: users(:user1).username }
        users(:user1).checkouts.returned.count.should eq 0
        response.should redirect_to checkouts_url
      end

      it 'should not remove other checkout history' do
        put :remove_all, params: { user_id: users(:user2).username }
        users(:user1).checkouts.returned.count.should_not eq 0
        response.should redirect_to checkouts_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested checkout' do
          put :update, params: { id: @checkout.id, checkout: @attrs, user_id: @checkout.user.username }
        end

        it 'assigns the requested checkout as @checkout' do
          put :update, params: { id: @checkout.id, checkout: @attrs, user_id: @checkout.user.username }
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(assigns(:checkout))
        end
      end

      describe 'with invalid params' do
        it 'assigns the checkout as @checkout' do
          put :update, params: { id: @checkout.id, checkout: @invalid_attrs, user_id: @checkout.user.username }
          assigns(:checkout).should be_valid
        end

        it 'should ignore item_id' do
          put :update, params: { id: @checkout.id, checkout: @invalid_attrs, user_id: @checkout.user.username }
          response.should redirect_to(assigns(:checkout))
        end
      end

      it 'should update checkout item that is reserved' do
        put :update, params: { id: 8, checkout: {} }
        assigns(:checkout).errors[:base].include?(I18n.t('checkout.this_item_is_reserved')).should be_truthy
        response.should be_successful
      end

      it "should update other user's checkout" do
        put :update, params: { id: 1, checkout: {} }
        response.should redirect_to checkout_url(assigns(:checkout))
      end

      it 'should remove its own checkout history' do
        put :remove_all, params: { user_id: users(:user1).username }
        users(:user1).checkouts.returned.count.should eq 0
        response.should redirect_to checkouts_url
      end

      it 'should not remove other checkout history' do
        put :remove_all, params: { user_id: users(:user2).username }
        users(:user1).checkouts.returned.count.should_not eq 0
        response.should redirect_to checkouts_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested checkout' do
          put :update, params: { id: checkouts(:checkout_00001).id, checkout: @attrs }
        end

        it 'assigns the requested checkout as @checkout' do
          put :update, params: { id: checkouts(:checkout_00001).id, checkout: @attrs }
          assigns(:checkout).should eq(checkouts(:checkout_00001))
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested checkout as @checkout' do
          put :update, params: { id: checkouts(:checkout_00001).id, checkout: @attrs }
          response.should be_forbidden
        end
      end

      it "should not update other user's checkout" do
        put :update, params: { id: 1, checkout: {} }
        response.should be_forbidden
      end

      it 'should not update checkout already renewed' do
        put :update, params: { id: 9, checkout: {} }
        assigns(:checkout).errors[:base].include?(I18n.t('checkout.excessed_renewal_limit')).should be_truthy
        response.should be_successful
      end

      it 'should update my checkout' do
        put :update, params: { id: 3, checkout: {} }
        assigns(:checkout).should be_valid
        response.should redirect_to checkout_url(assigns(:checkout))
      end

      it 'should not update checkout without item_id' do
        put :update, params: { id: 3, checkout: { item_id: nil } }
        assigns(:checkout).should be_valid
        response.should redirect_to(assigns(:checkout))
        assigns(:checkout).changed?.should be_falsy
      end

      it 'should remove its own checkout history' do
        put :remove_all, params: { user_id: users(:user1).username }
        assigns(:user).checkouts.returned.count.should eq 0
        response.should redirect_to checkouts_url
      end

      it 'should not remove other checkout history' do
        put :remove_all, params: { user_id: users(:admin).username }
        assigns(:user).checkouts.returned.count.should eq 0
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested checkout' do
          put :update, params: { id: @checkout.id, checkout: @attrs, user_id: @checkout.user.username }
        end

        it 'should be forbidden' do
          put :update, params: { id: @checkout.id, checkout: @attrs, user_id: @checkout.user.username }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested checkout as @checkout' do
          put :update, params: { id: @checkout.id, checkout: @invalid_attrs, user_id: @checkout.user.username }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
      @returned_checkout = checkouts(:checkout_00012)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested checkout' do
        delete :destroy, params: { id: @checkout.id }
      end

      it 'should not destroy the checkout that is not checked in' do
        delete :destroy, params: { id: @checkout.id }
        response.should be_forbidden
      end

      it 'redirects to the checkouts list' do
        delete :destroy, params: { id: @returned_checkout.id }
        response.should redirect_to(checkouts_url(user_id: @returned_checkout.user.username))
      end

      it 'should be forbidden to delete a checkout if its user is not set' do
        delete :destroy, params: { id: @returned_checkout.id }
        delete :destroy, params: { id: @returned_checkout.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested checkout' do
        delete :destroy, params: { id: @checkout.id }
      end

      it 'should not destroy the checkout that is not checked in' do
        delete :destroy, params: { id: @checkout.id }
        response.should be_forbidden
      end

      it 'redirects to the checkouts list' do
        delete :destroy, params: { id: @returned_checkout.id }
        response.should redirect_to(checkouts_url(user_id: @returned_checkout.user.username))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested checkout' do
        delete :destroy, params: { id: checkouts(:checkout_00001).id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: checkouts(:checkout_00001).id }
        response.should be_forbidden
      end

      it 'should destroy my checkout' do
        delete :destroy, params: { id: 13 }
        response.should redirect_to checkouts_url(user_id: users(:user1).username)
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested checkout' do
        delete :destroy, params: { id: @checkout.id, user_id: @checkout.user.username }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @checkout.id, user_id: @checkout.user.username }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
