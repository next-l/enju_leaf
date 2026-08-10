require 'rails_helper'

describe ProfilesController do
  fixtures :all

  before(:each) do
    @admin_profile = FactoryBot.create(:admin).profile
    @librarian_profile = FactoryBot.create(:librarian).profile
  end

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all profiles as @profiles" do
        get :index
        expect(assigns(:profiles)).not_to be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all profiles as @profiles" do
        get :index
        expect(assigns(:profiles)).not_to be_nil
      end

      it "should get index with query" do
        get :index, params: { query: 'user1' }
        expect(response).to be_successful
        expect(assigns(:profiles)).not_to be_nil
      end

      it "should get sorted index" do
        get :index, params: { query: 'user1', sort_by: 'username', order: 'desc' }
        expect(response).to be_successful
        expect(assigns(:profiles)).not_to be_nil
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all profiles as @profiles" do
        get :index
        expect(assigns(:profiles)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all profiles as @profiles" do
        get :index
        expect(assigns(:profiles)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @profile" do
        get :show, params: { id: profiles(:profile_admin).id }
        expect(assigns(:profile)).to eq(profiles(:profile_admin))
      end
      it "assigns the another requested user as @profile" do
        get :show, params: { id: @admin_profile.id }
        expect(response).not_to be_forbidden
        expect(assigns(:profile)).to eq @admin_profile
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user as @profile" do
        get :show, params: { id: profiles(:profile_librarian1).id }
        expect(assigns(:profile)).to eq(profiles(:profile_librarian1))
      end
      it "should not assign the requested user as @admin" do
        get :show, params: { id: @admin_profile.id }
        expect(response).to be_forbidden
      end
      it "should assign the requested user as @librarian" do
        get :show, params: { id: @librarian_profile.id }
        expect(response).not_to be_forbidden
        expect(assigns(:profile)).to eq @librarian_profile
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user as @profile" do
        get :show, params: { id: profiles(:profile_user1).id }
        expect(assigns(:profile)).to eq(profiles(:profile_user1))
      end

      it "should redirect to my user account" do
        get :show, params: { id: profiles(:profile_user1).id }
        assert_redirected_to my_account_url
      end

      it "should show other user's account" do
        get :show, params: { id: profiles(:profile_admin).id }
        expect(assigns(:profile)).to eq(profiles(:profile_admin))
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested user as @profile" do
        get :show, params: { id: profiles(:profile_admin).id }
        expect(assigns(:profile)).to eq nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @profile" do
        get :new
        expect(assigns(:profile)).not_to be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested user as @profile" do
        get :new
        expect(assigns(:profile)).not_to be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user as @profile" do
        get :new
        expect(assigns(:profile)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @profile" do
        get :new
        expect(assigns(:profile)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @profile" do
        profile = FactoryBot.create(:profile)
        get :edit, params: { id: profile.id }
        expect(assigns(:profile)).to eq(profile)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should assign the requested user as @profile" do
        profile = FactoryBot.create(:profile)
        get :edit, params: { id: profile.id }
        expect(assigns(:profile)).to eq(profile)
      end
      it "should not get edit page for admin required user" do
        get :edit, params: { id: @admin_profile.id }
        expect(response).to be_forbidden
        # assigns(:profile).should_not eq(admin)
      end
      it "should get edit page for other librarian user" do
        get :edit, params: { id: @librarian_profile.id }
        expect(response).not_to be_forbidden
        expect(assigns(:profile)).to eq @librarian_profile
      end

      it "should get edit page for other librarian user" do
        get :edit, params: { id: @admin_profile.id }
        expect(response).to be_forbidden
        expect(assigns(:profile)).to eq @admin_profile
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user as @profile" do
        profile = FactoryBot.create(:profile)
        get :edit, params: { id: profile.id }
        expect(assigns(:profile)).to eq(profile)
        expect(response).to be_forbidden
      end

      it "should edit myself" do
        get :edit, params: { id: profiles(:profile_user1).id }
        expect(response).to redirect_to edit_my_account_url
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @profile" do
        profile = FactoryBot.create(:profile)
        get :edit, params: { id: profile.id }
        expect(assigns(:profile)).to eq nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:profile)
      @invalid_attrs = { user_group_id: '', user_number: '日本語' }
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created user as @profile" do
          post :create, params: { profile: @attrs }
          expect(assigns(:profile)).to be_valid
        end

        it "redirects to the created user" do
          post :create, params: { profile: @attrs }
          expect(response).to redirect_to(profile_url(assigns(:profile)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @profile" do
          post :create, params: { profile: @invalid_attrs }
          expect(assigns(:profile)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { profile: @invalid_attrs }
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created user as @profile" do
          post :create, params: { profile: @attrs }
          expect(assigns(:profile)).to be_valid
        end

        it "redirects to the created user" do
          post :create, params: { profile: @attrs }
          expect(response).to redirect_to(profile_url(assigns(:profile)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @profile" do
          post :create, params: { profile: @invalid_attrs }
          expect(assigns(:profile)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { profile: @invalid_attrs }
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not create user" do
        post :create, params: { profile: { username: 'test10' } }
        expect(assigns(:profile)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not create user" do
        post :create, params: { profile: { username: 'test10' } }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @profile = profiles(:profile_user1)
      @attrs = { user_group_id: '3', locale: 'en' }
      @invalid_attrs = { user_group_id: '', user_number: '日本語' }
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested user" do
          put :update, params: { id: @profile.id, profile: @attrs }
        end

        it "assigns the requested user as @profile" do
          put :update, params: { id: @profile.id, profile: @attrs }
          expect(assigns(:profile)).to eq(@profile)
        end

        it "redirects to the user" do
          put :update, params: { id: @profile.id, profile: @attrs }
          expect(assigns(:profile)).to eq(@profile)
          expect(response).to redirect_to(@profile)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @profile" do
          put :update, params: { id: @profile.id, profile: @invalid_attrs }
          expect(assigns(:profile)).to eq(@profile)
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @profile, profile: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end

      it "should update other user's role" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_attributes: { user_has_role_attributes: { role_id: 4 }, email: profiles(:profile_user1).user.email, locale: 'en', id: profiles(:profile_user1).user.id } } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        assigns(:profile).reload
        expect(assigns(:profile).user.role).to eq Role.where(name: 'Administrator').first
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested user" do
          put :update, params: { id: @profile.id, profile: @attrs }
        end

        it "assigns the requested user as @profile" do
          put :update, params: { id: @profile.id, profile: @attrs }
          expect(assigns(:profile)).to eq(@profile)
        end

        it "redirects to the user" do
          put :update, params: { id: @profile.id, profile: @attrs }
          expect(assigns(:profile)).to eq(@profile)
          expect(response).to redirect_to(@profile)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @profile" do
          put :update, params: { id: @profile, profile: @invalid_attrs }
          expect(assigns(:profile)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @profile, profile: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end

      it "should update other user" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_number: '00003', locale: 'en', user_group_id: 3, library_id: 3, note: 'test' } }
        expect(response).to redirect_to profile_url(assigns(:profile))
      end

      it "should not update other admin" do
        put :update, params: { id: profiles(:profile_admin).id, profile: { user_number: '00003', locale: 'en', user_group_id: 3, library_id: 3, note: 'test' } }
        expect(response).to be_forbidden
      end

      it "should update other user's user_group" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_group_id: 3, library_id: 3, locale: 'en' } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).user_group_id).to eq 3
      end

      it "should update other user's note" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_group_id: 3, library_id: 3, note: 'test', locale: 'en' } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        assert_equal assigns(:profile).note, 'test'
      end

      it "should update other user's locked status" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_attributes: { id: 3, locked: '1', username: 'user1' } } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).user.locked_at).to be_truthy
        expect(assigns(:profile).user.access_locked?).to be_truthy
      end

      it "should unlock other user" do
        profiles(:profile_user1).user.lock_access!
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_attributes: { id: 3, locked: '0', username: 'user1' } } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).user.locked_at).to be_falsy
        expect(assigns(:profile).user.access_locked?).to be_falsy
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested user" do
          put :update, params: { id: @profile.id, profile: @attrs }
        end

        it "assigns the requested user as @profile" do
          put :update, params: { id: @profile.id, profile: @attrs }
          expect(assigns(:profile)).to be_valid
          expect(response).to redirect_to profile_url(assigns(:profile))
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @profile" do
          put :update, params: { id: @profile.id, profile: @invalid_attrs }
          # assigns(:profile).should_not be_valid
          # response.should be_successful
          expect(assigns(:profile)).to be_valid
          expect(response).to redirect_to profile_url(assigns(:profile))
        end
      end

      it "should update myself" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { keyword_list: 'test' } }
        expect(response).to redirect_to profile_url(assigns(:profile))
      end

      it "should not update my role" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_has_role_attributes: { role_id: 4 } } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).user.role).not_to eq Role.where(name: 'Administrator').first
      end

      it "should not update my user_group" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_group_id: 3, library_id: 3 } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).user_group_id).to eq 1
      end

      it "should not update my note" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { user_group_id: 3, library_id: 3, note: 'test' } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).note).to be_nil
      end

      it "should update my keyword_list" do
        put :update, params: { id: profiles(:profile_user1).id, profile: { keyword_list: 'test' } }
        expect(response).to redirect_to profile_url(assigns(:profile))
        expect(assigns(:profile).keyword_list).to eq 'test'
        expect(assigns(:profile).user.role.name).to eq 'User'
      end

      it "should not update other user" do
        put :update, params: { id: profiles(:profile_user2).id, profile: {} }
        expect(assigns(:profile)).to be_valid
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, params: { id: @profile.id, profile: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @profile.id, profile: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @profile" do
          put :update, params: { id: @profile.id, profile: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested user" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
      end

      it "redirects to the profiles list" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
        expect(response).to redirect_to(profiles_url)
      end

      it "should destroy librarian" do
        delete :destroy, params: { id: profiles(:profile_librarian2).id }
        expect(response).to redirect_to(profiles_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested user" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
        expect(response).to redirect_to(profiles_url)
      end

      it "redirects to the profiles list" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
        expect(response).to redirect_to(profiles_url)
      end

      it "should not destroy librarian" do
        delete :destroy, params: { id: profiles(:profile_librarian2).id }
        expect(response).to be_forbidden
      end

      it "should not destroy admin" do
        delete :destroy, params: { id: profiles(:profile_admin).id }
        expect(response).to be_forbidden
      end

      it "should not destroy myself" do
        delete :destroy, params: { id: profiles(:profile_librarian1).id }
        expect(response).to be_forbidden
      end

      it "should not be able to delete other librarian user" do
        delete :destroy, params: { id: @librarian_profile.id }
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested user" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
        expect(response).to be_forbidden
      end

      it "should not destroy myself" do
        delete :destroy, params: { id: profiles(:profile_user1).id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
        expect(response).to redirect_to(new_user_session_url)
      end

      it "should be forbidden" do
        delete :destroy, params: { id: profiles(:profile_user2).id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
