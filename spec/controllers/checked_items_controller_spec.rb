require 'spec_helper'

describe CheckedItemsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all checked_items as @checked_items" do
        get :index
        assigns(:checked_items).should_not be_empty
        response.should be_forbidden
      end

      it "should not get index without basket_id" do
        get :index, :item_id => 1
        assigns(:checked_items).should_not be_empty
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should be forbidden" do
        get :index
        assigns(:checked_items).should_not be_empty
        response.should be_forbidden
      end

      describe "When basket is specified" do
        it "assigns checked_items as @checked_items" do
          get :index, :basket_id => 1
          assigns(:checked_items).should_not be_empty
          response.should be_success
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns empty as @checked_items" do
        get :index
        assigns(:checked_items).should be_empty
        response.should be_forbidden
      end

      it "should not get index" do
        get :index, :basket_id => 3, :item_id => 3
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @checked_items" do
        get :index
        assigns(:checked_items).should be_empty
        response.should redirect_to(new_user_session_url)
      end

      it "should not get index with basket_id and item_id" do
        get :index, :basket_id => 1, :item_id => 1
        assigns(:checked_items).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested checked_item as @checked_item" do
        get :show, :id => 1
        assigns(:checked_item).should eq(checked_items(:checked_item_00001))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested checked_item as @checked_item" do
        get :new, :basket_id => 3
        assigns(:checked_item).should_not be_valid
        response.should be_success
      end

      describe "When basket is not specified" do
        it "should be forbidden" do
          get :new
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested checked_item as @checked_item" do
        get :new, :basket_id => 3
        assigns(:checked_item).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested checked_item as @checked_item" do
        get :new, :basket_id => 3
        assigns(:checked_item).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checked_item as @checked_item" do
        get :new, :basket_id => 3
        assigns(:checked_item).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        assigns(:checked_item).should eq(checked_item)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        assigns(:checked_item).should eq(checked_item)
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checked_item as @checked_item" do
        checked_item = checked_items(:checked_item_00001)
        get :edit, :id => checked_item.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:item_identifier => '00011'}
      @invalid_attrs = {:item_identifier => 'invalid'}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "When the item is missing" do
        it "assigns a newly created checked_item as @checked_item" do
          post :create, :checked_item => {:item_identifier => 'not found'} , :basket_id => 1
          assigns(:checked_item).should_not be_valid
          assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.item_not_found')).should be_true
        end
      end

      describe "When the item is not for checkout" do
        it "assigns a newly created checked_item as @checked_item" do
          post :create, :checked_item => {:item_identifier => '00017'} , :basket_id => 1
          assigns(:checked_item).should_not be_valid
          assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout')).should be_true
        end
      end

      describe "When the item is already checked out" do
        it "assigns a newly created checked_item as @checked_item" do
          post :create, :checked_item => {:item_identifier => '00013'} , :basket_id => 8
          assigns(:checked_item).should_not be_valid
          assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.already_checked_out')).should be_true
        end
      end

      describe "When the item is in transaction" do
        it "assigns a newly created checked_item as @checked_item" do
          post :create, :checked_item => {:item_identifier => '00006'} , :basket_id => 9
          assigns(:checked_item).should_not be_valid
          assigns(:checked_item).errors[:base].include?(I18n.t('activerecord.errors.messages.checked_item.in_transcation')).should be_true
        end
      end

      describe "When the item is reserved" do
        it "assigns a newly created checked_item as @checked_item" do
          post :create, :checked_item => {:item_identifier => '00021'} , :basket_id => 11
          assigns(:checked_item).should be_valid
          assigns(:checked_item).item.manifestation.reserves.waiting.should be_empty
        end
      end

      it "should not create checked_item without basket_id" do
        post :create, :checked_item => {:item_identifier => '00004'}
        response.should be_forbidden
      end

      it "should not create checked_item without item_id" do
        post :create, :checked_item => { }, :basket_id => 1
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should create checked_item" do
        post :create, :checked_item => @attrs, :basket_id => 3
        assigns(:checked_item).due_date.should eq Time.zone.now.tomorrow.end_of_day
        response.should redirect_to basket_checked_items_url(assigns(:checked_item).basket)
      end

      it "should create checked_item with list" do
        post :create, :checked_item => {:item_identifier => '00011'}, :basket_id => 3, :mode => 'list'
        assigns(:checked_item).should be_true
        assigns(:checked_item).due_date.should_not be_nil
        response.should redirect_to basket_checked_items_url(assigns(:checked_item).basket, :mode => 'list')
      end 

      it "should not create checked_item if excessed checkout_limit" do
        post :create, :checked_item => {:item_identifier => '00011'}, :basket_id => 1
        response.should be_success
        assigns(:checked_item).errors["base"].include?(I18n.t('activerecord.errors.messages.checked_item.excessed_checkout_limit')).should be_true
      end

      it "should show message when the item includes supplements" do
        post :create, :checked_item => {:item_identifier => '00006'}, :basket_id => 3
        assigns(:checked_item).due_date.should_not be_nil
        response.should redirect_to basket_checked_items_url(assigns(:checked_item).basket)
        flash[:message].index(I18n.t('item.this_item_include_supplement')).should be_true
      end 

      it "should create checked_item when ignore_restrictoin is checked" do
        post :create, :checked_item => {:item_identifier => '00011', :ignore_restriction => "1"}, :basket_id => 2, :mode => 'list'
        assigns(:checked_item).due_date.should_not be_nil
        response.should redirect_to basket_checked_items_url(assigns(:checked_item).basket, :mode => 'list')
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not create checked_item" do
        post :create, :checked_item => {:item_identifier => '00004'}, :basket_id => 3
        response.should be_forbidden
      end
    end

    describe "When not logged in as" do
      it "should not create checked_item" do
        post :create, :checked_item => {:item_identifier => '00004'}, :basket_id => 1
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @attrs = {:item_identifier => '00011'}
      @invalid_attrs = {:item_identifier => 'invalid'}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should not update checked_item without basket_id" do
        put :update, :id => 1, :checked_item => { }
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not update checked_item without basket_id" do
        put :update, :id => 1, :checked_item => {}
        response.should be_forbidden
      end

      it "should update checked_item" do
        put :update, :id => 4, :checked_item => { }, :basket_id => 8
        assigns(:checked_item).should be_valid
        response.should redirect_to checked_item_url(assigns(:checked_item))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not update checked_item" do
        put :update, :id => 1, :checked_item => { }, :basket_id => 3
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update checed_item" do
        put :update, :id => 1, :checked_item => { }, :basket_id => 1
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should destroy checked_item" do
        delete :destroy, :id => 1
        response.should redirect_to basket_checked_items_url(assigns(:checked_item).basket)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should destroy checked_item" do
        delete :destroy, :id => 1
        response.should redirect_to basket_checked_items_url(assigns(:checked_item).basket)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not destroy checked_item" do
        delete :destroy, :id => 3
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not destroy checked_item" do
        delete :destroy, :id => 1
        response.should redirect_to new_user_session_url
      end
    end
  end
end
