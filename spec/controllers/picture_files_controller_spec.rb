require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe PictureFilesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all picture_files as @picture_files" do
        get :index
        assigns(:picture_files).should eq(PictureFile.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all picture_files as @picture_files" do
        get :index
        assigns(:picture_files).should eq(PictureFile.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all picture_files as @picture_files" do
        get :index
        assigns(:picture_files).should eq(PictureFile.all)
      end
    end

    describe "When not logged in" do
      it "assigns all picture_files as @picture_files" do
        get :index
        assigns(:picture_files).should eq(PictureFile.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :show, :id => picture_file.id
        assigns(:picture_file).should eq(picture_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :show, :id => picture_file.id
        assigns(:picture_file).should eq(picture_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :show, :id => picture_file.id
        assigns(:picture_file).should eq(picture_file)
      end
    end

    describe "When not logged in" do
      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :show, :id => picture_file.id
        assigns(:picture_file).should eq(picture_file)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested picture_file as @picture_file" do
        get :new
        assigns(:picture_file).should_not be_valid
        response.should redirect_to picture_files_url
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested picture_file as @picture_file" do
        get :new
        assigns(:picture_file).should_not be_valid
        response.should redirect_to picture_files_url
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested picture_file as @picture_file" do
        get :new
        assigns(:picture_file).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested picture_file as @picture_file" do
        get :new
        assigns(:picture_file).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :edit, :id => picture_file.id
        assigns(:picture_file).should eq(picture_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :edit, :id => picture_file.id
        assigns(:picture_file).should eq(picture_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :edit, :id => picture_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested picture_file as @picture_file" do
        picture_file = PictureFile.find(1)
        get :edit, :id => picture_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:picture_attachable_type => 'Shelf', :picture_attachable_id => 1, :picture => File.new("#{Rails.root.to_s}/examples/spinner.gif")}
      @invalid_attrs = {:filename => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created picture_file as @picture_file" do
          post :create, :picture_file => @attrs
          assigns(:picture_file).should be_valid
        end

        it "redirects to the created picture_file" do
          post :create, :picture_file => @attrs
          response.should redirect_to(picture_file_url(assigns(:picture_file)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved picture_file as @picture_file" do
          post :create, :picture_file => @invalid_attrs
          assigns(:picture_file).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :picture_file => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created picture_file as @picture_file" do
          post :create, :picture_file => @attrs
          assigns(:picture_file).should be_valid
        end

        it "redirects to the created picture_file" do
          post :create, :picture_file => @attrs
          response.should redirect_to(picture_file_url(assigns(:picture_file)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved picture_file as @picture_file" do
          post :create, :picture_file => @invalid_attrs
          assigns(:picture_file).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :picture_file => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created picture_file as @picture_file" do
          post :create, :picture_file => @attrs
          assigns(:picture_file).should be_valid
        end

        it "should be forbidden" do
          post :create, :picture_file => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved picture_file as @picture_file" do
          post :create, :picture_file => @invalid_attrs
          assigns(:picture_file).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :picture_file => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created picture_file as @picture_file" do
          post :create, :picture_file => @attrs
          assigns(:picture_file).should be_valid
        end

        it "should be forbidden" do
          post :create, :picture_file => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved picture_file as @picture_file" do
          post :create, :picture_file => @invalid_attrs
          assigns(:picture_file).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :picture_file => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @picture_file = picture_files(:picture_file_00001)
      @attrs = {:filename => 'new filename.txt'}
      @invalid_attrs = {:picture_attachable_type => nil}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
        end

        it "assigns the requested picture_file as @picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
          assigns(:picture_file).should eq(@picture_file)
        end

        it "moves its position when specified" do
          put :update, :id => @picture_file.id, :position => 2
          response.should redirect_to(shelf_picture_files_url(@picture_file.picture_attachable))
        end
      end

      describe "with invalid params" do
        it "assigns the requested picture_file as @picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
        end

        it "assigns the requested picture_file as @picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
          assigns(:picture_file).should eq(@picture_file)
          response.should redirect_to(@picture_file)
        end
      end

      describe "with invalid params" do
        it "assigns the picture_file as @picture_file" do
          put :update, :id => @picture_file, :picture_file => @invalid_attrs
          assigns(:picture_file).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @picture_file, :picture_file => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
        end

        it "assigns the requested picture_file as @picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
          assigns(:picture_file).should eq(@picture_file)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested picture_file as @picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @picture_file.id, :picture_file => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested picture_file as @picture_file" do
          put :update, :id => @picture_file.id, :picture_file => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @picture_file = PictureFile.find(1)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested picture_file" do
        delete :destroy, :id => @picture_file.id
      end

      it "redirects to the picture_files list" do
        delete :destroy, :id => @picture_file.id
        response.should redirect_to(picture_files_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested picture_file" do
        delete :destroy, :id => @picture_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @picture_file.id
        response.should redirect_to(picture_files_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested picture_file" do
        delete :destroy, :id => @picture_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @picture_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested picture_file" do
        delete :destroy, :id => @picture_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @picture_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
