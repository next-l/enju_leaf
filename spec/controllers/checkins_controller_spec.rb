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
      login_admin

      it "assigns nil as @checkins" do
        get :index
        assigns(:checkins).should be_nil
        response.should redirect_to(basket_checkins_url(assigns(:basket)))
      end

      describe "When basket_id is specified" do
        it "assigns all checkins as @checkins" do
          get :index, :basket_id => 10
          assigns(:checkins).should eq Basket.find(10).checkins
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns nil as @checkins" do
        get :index
        assigns(:checkins).should be_nil
        response.should redirect_to(basket_checkins_url(assigns(:basket)))
      end

      describe "When basket_id is specified" do
        it "assigns all checkins as @checkins" do
          get :index, :basket_id => 9
          assigns(:checkins).should eq Basket.find(9).checkins
          response.should be_success
        end
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign all checkins as @checkins" do
        get :index
        assigns(:checkins).should be_nil
        response.should be_forbidden
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :show, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end

      it "should not show missing checkin" do
        get :show, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :show, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested checkin as @checkin" do
        get :new
        assigns(:checkin).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested checkin as @checkin" do
        get :new
        assigns(:checkin).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :edit, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
  
      it "should not edit missing checkin" do
        get :edit, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested checkin as @checkin" do
        checkin = checkins(:checkin_00001)
        get :edit, :id => checkin.id
        assigns(:checkin).should eq(checkin)
      end
    end

    describe "When logged in as User" do
      login_user

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
    before(:each) do
      @attrs = {:item_identifier => '00003'}
      @invalid_attrs = {:item_identifier => 'invalid'}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created checkin as @checkin" do
          post :create, :checkin => @attrs
          assigns(:checkin).should be_valid
        end

        it "redirects to index" do
          post :create, :checkin => @attrs
          response.should redirect_to(basket_checkins_url(assigns(:basket)))
          assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
        end

        describe "When basket_id is specified" do
          it "redirects to the created checkin" do
            post :create, :checkin => @attrs, :basket_id => 9
            response.should redirect_to(basket_checkins_url(assigns(:checkin).basket))
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
          response.should redirect_to(basket_checkins_url(assigns(:checkin).basket))
        end
      end

      it "should not create checkin without item_id" do
        post :create, :checkin => {:item_identifier => nil}, :basket_id => 9
        assigns(:checkin).should_not be_valid
        response.should redirect_to basket_checkins_url(assigns(:basket))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created checkin as @checkin" do
          post :create, :checkin => @attrs
          assigns(:checkin).should be_valid
          assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
        end

        it "should show notification when it is reserved" do
          post :create, :checkin => {:item_identifier => '00008'}, :basket_id => 9
          flash[:message].to_s.index(I18n.t('item.this_item_is_reserved')).should be_true
          assigns(:checkin).item.manifestation.next_reservation.state.should eq 'retained'
          assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
          response.should redirect_to basket_checkins_url(assigns(:basket))
        end

        it "should show notification when an item includes supplements" do
          post :create, :checkin => {:item_identifier => '00004'}, :basket_id => 9
          assigns(:checkin).item.circulation_status.name.should eq 'Available On Shelf'
          flash[:message].to_s.index(I18n.t('item.this_item_include_supplement')).should be_true
          response.should redirect_to basket_checkins_url(assigns(:basket))
        end
      end

      it "should show notice when other library's item is checked in" do
        sign_in users(:librarian2)
        post :create, :checkin => {:item_identifier => '00009'}, :basket_id => 9
        assigns(:checkin).should be_valid
        flash[:message].to_s.index(I18n.t('checkin.other_library_item')).should be_true
        response.should redirect_to basket_checkins_url(assigns(:basket))
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created checkin as @checkin" do
          post :create, :checkin => @attrs
          assigns(:checkin).should be_valid
        end

        it "should be forbidden" do
          post :create, :checkin => @attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      before(:each) do
        @attrs = {:item_identifier => '00003'}
        @invalid_attrs = {:item_identifier => 'invalid'}
      end

      describe "with valid params" do
        it "assigns a newly created checkin as @checkin" do
          post :create, :checkin => @attrs
        end

        it "should redirect to new session url" do
          post :create, :checkin => @attrs
          response.should redirect_to new_user_session_url
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
      login_admin

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

        it "should not update checkin without item_identifier" do
          put :update, :id => @checkin.id, :checkin => @attrs.merge(:item_identifier => nil)
          assigns(:checkin).should_not be_valid
          response.should be_success
        end
      end

      it "should not update missing checkin" do
        put :update, :id => 'missing', :checkin => { }
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

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
      login_user

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
      login_admin

      it "destroys the requested checkin" do
        delete :destroy, :id => @checkin.id
      end

      it "redirects to the checkins list" do
        delete :destroy, :id => @checkin.id
        response.should redirect_to(checkins_url)
      end

      it "should not destroy missing checkin" do
        delete :destroy, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested checkin" do
        delete :destroy, :id => @checkin.id
      end

      it "redirects to the checkins list" do
        delete :destroy, :id => @checkin.id
        response.should redirect_to(checkins_url)
      end
    end

    describe "When logged in as User" do
      login_user

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
