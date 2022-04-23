require 'rails_helper'

describe TagsController do
  fixtures :all

  describe "GET index", solr: true do
    before do
      Tag.reindex
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all tags as @tags" do
        get :index
        expect(assigns(:tags)).not_to be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all tags as @tags" do
        get :index
        expect(assigns(:tags)).not_to be_nil
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all tags as @tags" do
        get :index
        expect(assigns(:tags)).not_to be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all tags as @tags" do
        get :index
        expect(assigns(:tags)).not_to be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :show, params: { id: tag.name }
        expect(assigns(:tag)).to eq(tag)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :show, params: { id: tag.name }
        expect(assigns(:tag)).to eq(tag)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :show, params: { id: tag.name }
        expect(assigns(:tag)).to eq(tag)
      end
    end

    describe "When not logged in" do
      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :show, params: { id: tag.name }
        expect(assigns(:tag)).to eq(tag)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :edit, params: { id: tag.name }
        expect(assigns(:tag)).to eq(tag)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :edit, params: { id: tag.name }
        expect(assigns(:tag)).to eq(tag)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :edit, params: { id: tag.name }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested tag as @tag" do
        tag = FactoryBot.create(:tag)
        get :edit, params: { id: tag.name }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @tag = FactoryBot.create(:tag)
      @attrs = FactoryBot.attributes_for(:tag)
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
        end

        it "assigns the requested tag as @tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
          expect(assigns(:tag)).to eq(@tag)
          expect(response).to redirect_to(assigns(:tag))
        end
      end

      describe "with invalid params" do
        it "assigns the requested tag as @tag" do
          put :update, params: { id: @tag.name, tag: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @tag.name, tag: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
        end

        it "assigns the requested tag as @tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
          expect(assigns(:tag)).to eq(@tag)
          expect(response).to redirect_to(assigns(:tag))
        end
      end

      describe "with invalid params" do
        it "assigns the tag as @tag" do
          put :update, params: { id: @tag.name, tag: @invalid_attrs }
          expect(assigns(:tag)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @tag.name, tag: @invalid_attrs }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
        end

        it "assigns the requested tag as @tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
          expect(assigns(:tag)).to eq(@tag)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested tag as @tag" do
          put :update, params: { id: @tag.name, tag: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested tag" do
          put :update, params: { id: @tag.name, tag: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @tag.name, tag: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested tag as @tag" do
          put :update, params: { id: @tag.name, tag: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @tag = FactoryBot.create(:tag)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested tag" do
        delete :destroy, params: { id: @tag.name }
      end

      it "redirects to the tags list" do
        delete :destroy, params: { id: @tag.name }
        expect(response).to redirect_to(tags_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested tag" do
        delete :destroy, params: { id: @tag.name }
      end

      it "redirects to the tags list" do
        delete :destroy, params: { id: @tag.name }
        expect(response).to redirect_to(tags_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested tag" do
        delete :destroy, params: { id: @tag.name }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @tag.name }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested tag" do
        delete :destroy, params: { id: @tag.name }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @tag.name }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
