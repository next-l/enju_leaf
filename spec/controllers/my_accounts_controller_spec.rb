require 'spec_helper'

describe MyAccountsController do
  fixtures :all

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in User.find('admin')
      end

      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        assigns(:user).should eq(User.find('admin'))
      end
    end

    describe "When not logged in" do
      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        assigns(:user).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "When filename parameter was passed" do
      before(:each) do
        @tmpdir = Dir.mktmpdir
        @save_base_dir = UserFile.base_dir
        UserFile.base_dir = @tmpdir

        user = User.find('admin')
        @filename = 'foobar.pdf'
        @file, @info = UserFile.new(user).create(:manifestation_list, @filename)
        sign_in user
      end

      after(:each) do
        UserFile.base_dir = @save_base_dir
        FileUtils.remove_entry_secure(@tmpdir)
      end

      it "finds files with specified conditions and assigns the path of found file as @user_file" do
        get :show, :filename => @info[:filename], :category => @info[:category], :random => @info[:random]
        assigns(:user_file).should be_present
        assigns(:user_file).should == @file.path
        response.should be_success
      end

      it "send_file @user_file" do
        controller.
          should_receive(:send_file).
          with(@file.path, :filename => @filename, :type => Mime::Type.lookup("application/pdf")).
          and_return { controller.render :nothing => true }
        get :show, :filename => @info[:filename], :category => @info[:category], :random => @info[:random]
        response.should be_success
      end

      it "assigns nil as @user_file if parameters were wrong" do
        get :show, :filename => @info[:filename], :category => @info[:category], :random => @info[:random].reverse
        assigns(:user_file).should be_blank
        response.should be_not_found
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        @user = User.find('admin')
        sign_in @user
      end

      it "assigns the requested user as @user" do
        get :edit
        assigns(:user).should eq(@user)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "should assign the requested user as @user" do
        get :edit
        assigns(:user).should eq(@user)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "should assign the requested user as @user" do
        get :edit
        assigns(:user).should eq(@user)
        response.should be_success
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        get :edit
        assigns(:user).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @attrs = {:email => 'newaddress@example.jp', :locale => 'en', :current_password => 'password'}
      @invalid_attrs = {:username => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin, :password => 'password', :password_confirmation => 'password')
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :user => @attrs
          assigns(:user).should eq(@user)
        end

        it "redirects to the user" do
          put :update, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :user => @invalid_attrs
          assigns(:user).should eq(@user)
        end

        it "re-renders the 'edit' template" do
          put :update, :user => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian, :password => 'password', :password_confirmation => 'password')
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :user => @attrs
          assigns(:user).should eq(@user)
        end

        it "redirects to the user" do
          put :update, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @user" do
          put :update, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :user => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user, :password => 'password', :password_confirmation => 'password')
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :user => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "should be forbidden" do
          put :update, :user => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :user => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end
end
