require 'rails_helper'

describe BookmarksController do
  fixtures :all

  describe "GET index", solr: true do
    before do
      Bookmark.reindex
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all bookmarks as @bookmarks" do
        get :index
        expect(assigns(:bookmarks)).not_to be_empty
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all bookmarks as @bookmarks" do
        get :index
        expect(assigns(:bookmarks)).not_to be_empty
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all bookmarks as @bookmarks" do
        get :index
        expect(assigns(:bookmarks)).not_to be_empty
      end

      it "should get my bookmark index" do
        get :index
        expect(response).to be_successful
        expect(assigns(:bookmarks)).to eq users(:user1).bookmarks.page(1)
      end

      it "should redirect to my bookmark index if user_id is specified" do
        get :index, params: { user_id: users(:user1).username }
        expect(response).to redirect_to bookmarks_url
        expect(assigns(:bookmarks)).to be_nil
      end

      it "should get other user's public bookmark index" do
        get :index, params: { user_id: users(:admin).username }
        expect(response).to be_successful
        expect(assigns(:bookmarks)).to eq users(:admin).bookmarks.page(1)
      end

      it "should not get other user's private bookmark index" do
        sign_in users(:user3)
        get :index, params: { user_id: users(:user1).username }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns nil as @bookmarks" do
        get :index
        expect(assigns(:bookmarks)).to be_nil
      end

      it "should be redirected to new_user_session_url " do
        get :index
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark as @bookmark" do
        bookmark = FactoryBot.create(:bookmark)
        get :show, params: { id: bookmark.id }
        expect(assigns(:bookmark)).to eq(bookmark)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark as @bookmark" do
        bookmark = FactoryBot.create(:bookmark)
        get :show, params: { id: bookmark.id }
        expect(assigns(:bookmark)).to eq(bookmark)
      end

      it "should shot other user's bookmark" do
        get :show, params: { id: 3 }
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested bookmark as @bookmark" do
        bookmark = FactoryBot.create(:bookmark)
        get :show, params: { id: bookmark.id }
        expect(assigns(:bookmark)).to eq(bookmark)
      end

      it "should not show other user's bookmark" do
        get :show, params: { id: 1 }
        expect(response).to be_forbidden
      end

      it "should show my bookmark" do
        get :show, params: { id: 3 }
        expect(response).to be_successful
      end
    end

    describe "When not logged in" do
      it "assigns the requested bookmark as @bookmark" do
        bookmark = FactoryBot.create(:bookmark)
        get :show, params: { id: bookmark.id }
        expect(assigns(:bookmark)).to eq(bookmark)
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark as @bookmark" do
        get :new, params: { bookmark: { title: 'test' } }
        expect(assigns(:bookmark)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark as @bookmark" do
        get :new, params: { bookmark: { title: 'test' } }
        expect(assigns(:bookmark)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should get my new template without url" do
        get :new, params: { bookmark: { title: 'test' } }
        expect(assigns(:bookmark)).not_to be_valid
        expect(response).to be_successful
      end

      it "should not get new template with url already bookmarked" do
        get :new, params: { bookmark: {url: 'http://www.slis.keio.ac.jp/'} }
        expect(response).to be_successful
      end

      it "should get my new template with external url" do
        get :new, params: { bookmark: {title: 'example', url: 'http://example.com'} }
        expect(response).to be_successful
      end

      it "should get my new template with internal url" do
        get :new, params: { bookmark: {url: "#{LibraryGroup.site_config.url}/manifestations/1"} }
        expect(response).to be_successful
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested bookmark as @bookmark" do
        get :edit, params: { id: 3 }
        expect(assigns(:bookmark)).to eq(Bookmark.find(3))
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested bookmark as @bookmark" do
        get :edit, params: { id: 3 }
        expect(assigns(:bookmark)).to eq(Bookmark.find(3))
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not edit other user's bookmark" do
        get :edit, params: { id: 1 }
        expect(response).to be_forbidden
      end

      it "should edit my bookmark" do
        get :edit, params: { id: 3 }
        expect(assigns(:bookmark)).to eq(Bookmark.find(3))
        expect(response).to be_successful
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark as @bookmark" do
        get :edit, params: { id: 1 }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @bookmark = bookmarks(:bookmark_00001)
      @attrs = FactoryBot.attributes_for(:bookmark)
      @invalid_attrs = {url: ''}
    end

    describe "When logged in as User" do
      login_fixture_user
      #      before(:each) do
      #        @user = FactoryBot.create(:user)
      #        sign_in @user
      #      end

      it "should create bookmark" do
        post :create, params: { bookmark: {title: 'example', url: 'http://www1.example.com/'} }
        assigns(:bookmark).save!
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should create bookmark with local url" do
        post :create, params: { bookmark: {title: 'example', url: "#{LibraryGroup.site_config.url}manifestations/10"} }
        expect(assigns(:bookmark)).to be_valid
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should create bookmark with tag_list" do
        old_tag_count = Tag.count
        post :create, params: { bookmark: {tag_list: 'search', title: 'example', url: 'http://example.com/'} }
        assigns(:bookmark).tag_list.should eq ['search']
        assigns(:bookmark).taggings.size.should eq 1
        Tag.count.should eq old_tag_count + 1
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should create bookmark with tag_list include wide space" do
        old_tag_count = Tag.count
        post :create, params: { bookmark: {tag_list: 'タグの　テスト', title: 'example', url: 'http://example.com/'} }
        Tag.count.should eq old_tag_count + 2
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should not create bookmark without url" do
        post :create, params: { bookmark: {title: 'test'} }
        expect(assigns(:bookmark)).not_to be_valid
        expect(response).to be_successful
      end

      it "should not create bookmark already bookmarked" do
        post :create, params: { bookmark: {user_id: users(:user1).id, url: 'http://www.slis.keio.ac.jp/'} }
        expect(assigns(:bookmark)).not_to be_valid
        expect(response).to be_successful
      end

      it "should not create other user's bookmark" do
        old_bookmark_counts = users(:user2).bookmarks.count
        post :create, params: { bookmark: {user_id: users(:user2).id, title: 'example', url: 'http://example.com/'} }
        users(:user2).bookmarks.count.should eq old_bookmark_counts
        assigns(:bookmark).user.should eq users(:user1)
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created bookmark as @bookmark" do
          post :create, params: { bookmark: @attrs }
          expect(assigns(:bookmark)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { bookmark: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark as @bookmark" do
          post :create, params: { bookmark: @invalid_attrs }
          expect(assigns(:bookmark)).to be_nil
        end

        it "should be forbidden" do
          post :create, params: { bookmark: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @bookmark = bookmarks(:bookmark_00001)
      @attrs = FactoryBot.attributes_for(:bookmark)
      @invalid_attrs = {url: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
        end

        it "assigns the requested bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
          expect(assigns(:bookmark)).to eq(@bookmark)
          expect(response).to redirect_to bookmark_url(@bookmark)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @bookmark.id, bookmark: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
        end

        it "assigns the requested bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
          expect(assigns(:bookmark)).to eq(@bookmark)
          expect(response).to redirect_to bookmark_url(@bookmark)
        end
      end

      describe "with invalid params" do
        it "assigns the bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @invalid_attrs }
          expect(assigns(:bookmark)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @bookmark.id, bookmark: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
        end

        it "assigns the requested bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
          expect(assigns(:bookmark)).to eq(@bookmark)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end

      it "should update bookmark" do
        put :update, params: { id: 3, bookmark: { title: 'test' } }
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
      end

      it "should add tags to bookmark" do
        put :update, params: { id: 3, bookmark: {user_id: users(:user1).id, tag_list: 'search', title: 'test'} }
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
        assigns(:bookmark).tag_list.should eq ['search']
      end

      it "should remove tags from bookmark" do
        put :update, params: { id: 3, bookmark: {user_id: users(:user1).id, tag_list: nil, title: 'test'} }
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
        assigns(:bookmark).tag_list.should be_empty
      end

      it "should not update other user's bookmark" do
        put :update, params: { id: 1, bookmark: { } }
        expect(response).to be_forbidden
      end

      it "should not update missing bookmark" do
        lambda{
          put :update, params: { id: 'missing', bookmark: { } }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # expect(response).to be_missing
      end

      it "should update bookmark without manifestation_id" do
        put :update, params: { id: 3, bookmark: {manifestation_id: nil} }
        expect(assigns(:bookmark)).to be_valid
        expect(response).to redirect_to bookmark_url(assigns(:bookmark))
        assigns(:bookmark).manifestation.should_not be_nil
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @bookmark.id, bookmark: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark as @bookmark" do
          put :update, params: { id: @bookmark.id, bookmark: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
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
        delete :destroy, params: { id: @bookmark.id }
      end

      it "redirects to the bookmarks list" do
        delete :destroy, params: { id: @bookmark.id }
        expect(response).to redirect_to bookmarks_url(user_id: @bookmark.user.username)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested bookmark" do
        delete :destroy, params: { id: @bookmark.id }
      end

      it "redirects to the bookmarks list" do
        delete :destroy, params: { id: @bookmark.id }
        expect(response).to redirect_to bookmarks_url(user_id: @bookmark.user.username)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested bookmark" do
        delete :destroy, params: { id: @bookmark.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @bookmark.id }
        expect(response).to be_forbidden
      end

      it "should destroy my bookmark" do
        delete :destroy, params: { id: 3 }
        expect(response).to redirect_to bookmarks_url(user_id: users(:user1).username)
      end

      it "should not destroy other user's bookmark" do
        delete :destroy, params: { id: 1 }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested bookmark" do
        delete :destroy, params: { id: @bookmark.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @bookmark.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
