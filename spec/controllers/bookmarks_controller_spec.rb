# -*- encoding: utf-8 -*-
require 'spec_helper'

describe BookmarksController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:bookmark)
  end

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all bookmarks as @bookmarks" do
        get :index
        assigns(:bookmarks).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all bookmarks as @bookmarks" do
        get :index
        assigns(:bookmarks).should_not be_empty
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all bookmarks as @bookmarks" do
        get :index
        assigns(:bookmarks).should_not be_empty
      end

      it "should get my bookmark index" do
        get :index
        response.should be_success
        assigns(:bookmarks).should eq users(:user1).bookmarks.page(1)
      end

      it "should redirect to my bookmark index if user_id is specified" do
        get :index, :user_id => users(:user1).username
        response.should redirect_to bookmarks_url
        assigns(:bookmarks).should be_nil
      end

      it "should get other user's public bookmark index" do
        get :index, :user_id => users(:admin).username
        response.should be_success
        assigns(:bookmarks).should eq users(:admin).bookmarks.page(1)
      end

      it "should not get other user's private bookmark index" do
        sign_in users(:user3)
        get :index, :user_id => users(:user1).username
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns nil as @bookmarks" do
        get :index
        assigns(:bookmarks).should be_nil
      end

      it "should be redirected to new_user_session_url "do
        get :index
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @bookmark = FactoryGirl.create(:bookmark)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark as @bookmark" do
        get :show, :id => @bookmark.id
        assigns(:bookmark).should eq(@bookmark)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark as @bookmark" do
        get :show, :id => @bookmark.id
        assigns(:bookmark).should eq(@bookmark)
      end

      it "should shot other user's bookmark" do
        get :show, :id => 3
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested bookmark as @bookmark" do
        get :show, :id => @bookmark.id
        assigns(:bookmark).should eq(@bookmark)
      end

      it "should not show other user's bookmark" do
        get :show, :id => 1
        response.should be_forbidden
      end
  
      it "should show my bookmark" do
        get :show, :id => 3
        response.should be_success
      end
    end

    describe "When not logged in" do
      it "assigns the requested bookmark as @bookmark" do
        get :show, :id => @bookmark.id
        assigns(:bookmark).should eq(@bookmark)
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark as @bookmark" do
        get :new
        assigns(:bookmark).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark as @bookmark" do
        get :new
        assigns(:bookmark).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should get my new template without url" do
        get :new
        assigns(:bookmark).should_not be_valid
        response.should be_success
      end
  
      it "should not get new template with url already bookmarked" do
        get :new, :bookmark => {:url => 'http://www.slis.keio.ac.jp/'}
        response.should be_success
      end
  
      it "should get my new template with external url" do
        get :new, :bookmark => {:title => 'example', :url => 'http://example.com'}
        response.should be_success
      end
  
      it "should get my new template with internal url" do
        get :new, :bookmark => {:url => "#{LibraryGroup.site_config.url}/manifestations/1"}
        response.should be_success
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark as @bookmark" do
        get :edit, :id => 3
        assigns(:bookmark).should eq(Bookmark.find(3))
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark as @bookmark" do
        get :edit, :id => 3
        assigns(:bookmark).should eq(Bookmark.find(3))
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not edit other user's bookmark" do
        get :edit, :id => 1
        response.should be_forbidden
      end
  
      it "should edit my bookmark" do
        get :edit, :id => 3
        assigns(:bookmark).should eq(Bookmark.find(3))
        response.should be_success
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark as @bookmark" do
        get :edit, :id => 1
        response.should redirect_to(new_user_session_url)
      end
    end
  end
  
  describe "POST create" do
    before(:each) do
      @bookmark = bookmarks(:bookmark_00001)
      @attrs = valid_attributes
      @invalid_attrs = {:url => ''}
    end

    describe "When logged in as User" do
      login_fixture_user
#      before(:each) do
#        @user = FactoryGirl.create(:user)
#        sign_in @user
#      end

      it "should create bookmark" do
        post :create, :bookmark => {:title => 'example', :url => 'http://www1.example.com/'}
        assigns(:bookmark).save!
        response.should redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should create bookmark with local url" do
        post :create, :bookmark => {:title => 'example', :url => "#{LibraryGroup.site_config.url}manifestations/10"}
        assigns(:bookmark).should be_valid
        response.should redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should create bookmark with tag_list" do
        old_tag_count = Tag.count
        post :create, :bookmark => {:tag_list => 'search', :title => 'example', :url => 'http://example.com/'}
        assigns(:bookmark).tag_list.should eq ['search']
        assigns(:bookmark).taggings.size.should eq 1
        Tag.count.should eq old_tag_count + 1
        response.should redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should create bookmark with tag_list include wide space" do
        old_tag_count = Tag.count
        post :create, :bookmark => {:tag_list => 'タグの　テスト', :title => 'example', :url => 'http://example.com/'}
        Tag.count.should eq old_tag_count + 2
        response.should redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should not create bookmark without url" do
        post :create, :bookmark => {:title => 'test'}
        assigns(:bookmark).should_not be_valid
        response.should be_success
      end

      it "should not create bookmark already bookmarked" do
        post :create, :bookmark => {:user_id => users(:user1).id, :url => 'http://www.slis.keio.ac.jp/'}
        assigns(:bookmark).should_not be_valid
        response.should be_success
      end

      it "should not create other user's bookmark" do
        old_bookmark_counts = users(:user2).bookmarks.count
        post :create, :bookmark => {:user_id => users(:user2).id, :title => 'example', :url => 'http://example.com/'}
        users(:user2).bookmarks.count.should eq old_bookmark_counts
        assigns(:bookmark).user.should eq users(:user1)
        response.should redirect_to bookmark_url(assigns(:bookmark))
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created bookmark as @bookmark" do
          post :create, :bookmark => @attrs
          assigns(:bookmark).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark as @bookmark" do
          post :create, :bookmark => @invalid_attrs
          assigns(:bookmark).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @bookmark = bookmarks(:bookmark_00001)
      @attrs = valid_attributes
      @invalid_attrs = {:url => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin)
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
        end

        it "assigns the requested bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
          assigns(:bookmark).should eq(@bookmark)
          response.should redirect_to bookmark_url(@bookmark)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @bookmark.id, :bookmark => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
        end

        it "assigns the requested bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
          assigns(:bookmark).should eq(@bookmark)
          response.should redirect_to bookmark_url(@bookmark)
        end
      end

      describe "with invalid params" do
        it "assigns the bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @invalid_attrs
          assigns(:bookmark).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @bookmark.id, :bookmark => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
        end

        it "assigns the requested bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
          assigns(:bookmark).should eq(@bookmark)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @invalid_attrs
          response.should be_forbidden
        end
      end

      it "should update bookmark" do
        put :update, :id => 3, :bookmark => { }
        response.should redirect_to bookmark_url(assigns(:bookmark))
      end
  
      it "should add tags to bookmark" do
        put :update, :id => 3, :bookmark => {:user_id => users(:user1).id, :tag_list => 'search', :title => 'test'}
        response.should redirect_to bookmark_url(assigns(:bookmark))
        assigns(:bookmark).tag_list.should eq ['search']
      end
  
      it "should remove tags from bookmark" do
        put :update, :id => 3, :bookmark => {:user_id => users(:user1).id, :tag_list => nil, :title => 'test'}
        response.should redirect_to bookmark_url(assigns(:bookmark))
        assigns(:bookmark).tag_list.should be_empty
      end

      it "should not update other user's bookmark" do
        put :update, :id => 1, :bookmark => { }
        response.should be_forbidden
      end

      it "should not update missing bookmark" do
        put :update, :id => 'missing', :bookmark => { }
        response.should be_missing
      end

      it "should not update bookmark without manifestation_id" do
        put :update, :id => 3, :bookmark => {:manifestation_id => nil}
        assigns(:bookmark).should_not be_valid
        response.should be_success
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @bookmark.id, :bookmark => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark as @bookmark" do
          put :update, :id => @bookmark.id, :bookmark => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @bookmark = bookmarks(:bookmark_00001)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested bookmark" do
        delete :destroy, :id => @bookmark.id
      end

      it "redirects to the bookmarks list" do
        delete :destroy, :id => @bookmark.id
        response.should redirect_to user_bookmarks_url(@bookmark.user)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested bookmark" do
        delete :destroy, :id => @bookmark.id
      end

      it "redirects to the bookmarks list" do
        delete :destroy, :id => @bookmark.id
        response.should redirect_to user_bookmarks_url(@bookmark.user)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested bookmark" do
        delete :destroy, :id => @bookmark.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark.id
        response.should be_forbidden
      end

      it "should destroy my bookmark" do
        delete :destroy, :id => 3
        response.should redirect_to user_bookmarks_url(users(:user1))
      end

      it "should not destroy other user's bookmark" do
        delete :destroy, :id => 1
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested bookmark" do
        delete :destroy, :id => @bookmark.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
