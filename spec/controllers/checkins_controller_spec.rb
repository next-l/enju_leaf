require 'spec_helper'

describe CheckinsController do
  fixtures :all

  def mock_user(stubs={})
    (@mock_user ||= mock_model(Checkin).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all checkins as @checkins" do
        get :index
        assigns(:checkins).should eq(Checkin.all)
        response.should redirect_to(user_basket_checkins_url(assigns(:basket).user, assigns(:basket)))
      end

      describe "When basket_id is specified" do
        it "assigns all checkins as @checkins" do
          get :index, :basket_id => 1
          assigns(:checkins).should eq(assigns(:basket).checkins)
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all checkins as @checkins" do
        get :index
        assigns(:checkins).should eq(Checkin.all)
        response.should redirect_to(user_basket_checkins_url(assigns(:basket).user, assigns(:basket)))
      end

      describe "When basket_id is specified" do
        it "assigns all checkins as @checkins" do
          get :index, :basket_id => 1
          assigns(:checkins).should eq(assigns(:basket).checkins)
          response.should be_success
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign all checkins as @checkins" do
        get :index
        assigns(:checkins).should be_empty
        response.should be_forbidden
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :show, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :show, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :show, :id => checkin.id
        assigns(:checkin).should eq(checkin)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :show, :id => checkin.id
        assigns(:checkin).should eq(checkin)
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested checkin as @checkin" do
        get :new
        assigns(:checkin).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested checkin as @checkin" do
        get :new
        assigns(:checkin).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested checkin as @checkin" do
        get :new
        assigns(:checkin).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checkin as @checkin" do
        get :new
        assigns(:checkin).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :edit, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :edit, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :edit, :id => checkin.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :edit, :id => checkin.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
        @attrs = {:item_identifier => '00003'}
        @invalid_attrs = {:item_identifier => 'invalid'}
      end

      describe "with valid params" do
        it "assigns a newly created checkin as @checkin" do
          post :create, :checkin => @attrs
          assigns(:checkin).should be_valid
        end

        it "redirects to index" do
          post :create, :checkin => @attrs
          response.should redirect_to(user_basket_checkins_url(assigns(:basket).user, assigns(:basket)))
          assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
        end

        describe "When basket_id is specified" do
          it "redirects to the created checkin" do
            post :create, :checkin => @attrs, :basket_id => 9
            response.should redirect_to(user_basket_checkins_url(assigns(:checkin).basket.user, assigns(:checkin).basket))
            assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
          end
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved checkin as @checkin" do
          post :create, :checkin => @invalid_attrs
          assigns(:checkin).should be_valid
        end

        it "redirects to the list" do
          post :create, :checkin => @invalid_attrs
          response.should redirect_to(user_basket_checkins_url(assigns(:checkin).basket.user, assigns(:checkin).basket))
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
        @attrs = {:item_identifier => '00003'}
        @invalid_attrs = {:item_identifier => 'invalid'}
      end

      describe "with valid params" do
        it "should show notification when it is reserved" do
          post :create, :checkin => {:item_identifier => '00008'}, :basket_id => 9
          flash[:message].to_s.index(I18n.t('item.this_item_is_reserved')).should be_true
          assigns(:checkin).item.next_reservation.state.should eq 'retained'
          assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
          response.should redirect_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @checkin = checkins(:checkin_00001)
      @attrs = {:item_identifier => @checkin.item.item_identifier, :librarian_id => FactoryGirl.create(:librarian).id}
      @invalid_attrs = {:basket_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
        end

        it "assigns the requested checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
          assigns(:checkin).should eq(@checkin)
          response.should redirect_to(@checkin)
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @checkin.id, :checkin => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
        end

        it "assigns the requested checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
          assigns(:checkin).should eq(@checkin)
          response.should redirect_to(@checkin)
        end
      end

      describe "with invalid params" do
        it "assigns the checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @invalid_attrs
          assigns(:checkin).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @checkin.id, :checkin => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
        end

        it "assigns the requested checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
          assigns(:checkin).should eq(@checkin)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested checkin" do
          put :update, :id => @checkin.id, :checkin => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @checkin.id, :checkin => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkin as @checkin" do
          put :update, :id => @checkin.id, :checkin => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @checkin = checkins(:checkin_00001)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested checkin" do
        delete :destroy, :id => @checkin.id
      end

      it "redirects to the checkins list" do
        delete :destroy, :id => @checkin.id
        response.should redirect_to(checkins_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested checkin" do
        delete :destroy, :id => @checkin.id
      end

      it "redirects to the checkins list" do
        delete :destroy, :id => @checkin.id
        response.should redirect_to(checkins_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested checkin" do
        delete :destroy, :id => @checkin.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkin.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested checkin" do
        delete :destroy, :id => @checkin.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkin.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
