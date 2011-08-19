require 'spec_helper'

describe RolesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all roles as @roles" do
        get :index
        assigns(:roles).should eq(Role.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all roles as @roles" do
        get :index
        assigns(:roles).should eq(Role.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all roles as @roles" do
        get :index
        assigns(:roles).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all roles as @roles" do
        get :index
        assigns(:roles).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested role as @role" do
        role = Role.find(1)
        get :show, :id => role.id
        assigns(:role).should eq(role)
      end
    end

    describe "When not logged in" do
      it "assigns the requested role as @role" do
        role = Role.find(1)
        get :show, :id => role.id
        assigns(:role).should eq(role)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested role as @role" do
        role = Role.find(1)
        get :edit, :id => role.id
        assigns(:role).should eq(role)
      end
    end

    describe "When not logged in" do
      it "should not assign the requested role as @role" do
        role = Role.find(1)
        get :edit, :id => role.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @role = Role.find(1)
      @attrs = {:display_name => 'guest user'}
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested role" do
          put :update, :id => @role.id, :role => @attrs
        end

        it "assigns the requested role as @role" do
          put :update, :id => @role.id, :role => @attrs
          assigns(:role).should eq(@role)
        end

        it "moves its position when specified" do
          put :update, :id => @role.id, :role => @attrs, :position => 2
          response.should redirect_to(roles_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested role as @role" do
          put :update, :id => @role.id, :role => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested role" do
          put :update, :id => @role.id, :role => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @role.id, :role => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested role as @role" do
          put :update, :id => @role.id, :role => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end
end
