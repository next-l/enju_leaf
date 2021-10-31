require 'rails_helper'

describe SubjectsController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:subject)
  end

  describe 'GET index', solr: true do
    before do
      Subject.reindex
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns all subjects as @subjects' do
        get :index
        expect(assigns(:subjects)).not_to be_nil
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns all subjects as @subjects' do
        get :index
        expect(assigns(:subjects)).not_to be_nil
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns all subjects as @subjects' do
        get :index
        expect(assigns(:subjects)).not_to be_nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all subjects as @subjects' do
        get :index
        response.should be_successful
        expect(assigns(:subjects)).not_to be_nil
      end
    end
  end

  describe 'GET show', solr: true do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :show, params: { id: subject.id }
        expect(assigns(:subject)).to eq(subject)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :show, params: { id: subject.id }
        expect(assigns(:subject)).to eq(subject)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :show, params: { id: subject.id }
        expect(assigns(:subject)).to eq(subject)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :show, params: { id: subject.id }
        expect(assigns(:subject)).to eq(subject)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested subject as @subject' do
        get :new
        expect(assigns(:subject)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested subject as @subject' do
        get :new
        expect(assigns(:subject)).to be_nil
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'should not assign the requested subject as @subject' do
        get :new
        expect(assigns(:subject)).to be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested subject as @subject' do
        get :new
        expect(assigns(:subject)).to be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :edit, params: { id: subject.id }
        expect(assigns(:subject)).to eq(subject)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :edit, params: { id: subject.id }
        expect(assigns(:subject)).to eq(subject)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :edit, params: { id: subject.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested subject as @subject' do
        subject = FactoryBot.create(:subject)
        get :edit, params: { id: subject.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { term: '' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'assigns a newly created subject as @subject' do
          post :create, params: { subject: @attrs }
          expect(assigns(:subject)).to be_valid
        end

        it 'redirects to the created subject' do
          post :create, params: { subject: @attrs }
          response.should redirect_to(subject_url(assigns(:subject)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subject as @subject' do
          post :create, params: { subject: @invalid_attrs }
          expect(assigns(:subject)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { subject: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'assigns a newly created subject as @subject' do
          post :create, params: { subject: @attrs }
          expect(assigns(:subject)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subject: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subject as @subject' do
          post :create, params: { subject: @invalid_attrs }
          expect(assigns(:subject)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subject: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'assigns a newly created subject as @subject' do
          post :create, params: { subject: @attrs }
          expect(assigns(:subject)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subject: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subject as @subject' do
          post :create, params: { subject: @invalid_attrs }
          expect(assigns(:subject)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subject: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created subject as @subject' do
          post :create, params: { subject: @attrs }
          expect(assigns(:subject)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subject: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subject as @subject' do
          post :create, params: { subject: @invalid_attrs }
          expect(assigns(:subject)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subject: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @subject = FactoryBot.create(:subject)
      @attrs = valid_attributes
      @invalid_attrs = { term: '' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'updates the requested subject' do
          put :update, params: { id: @subject.id, subject: @attrs }
        end

        it 'assigns the requested subject as @subject' do
          put :update, params: { id: @subject.id, subject: @attrs }
          expect(assigns(:subject)).to eq(@subject)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subject as @subject' do
          put :update, params: { id: @subject.id, subject: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'updates the requested subject' do
          put :update, params: { id: @subject.id, subject: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @subject.id, subject: @attrs }
          expect(assigns(:subject)).to eq(@subject)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'should be forbidden' do
          put :update, params: { id: @subject, subject: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'updates the requested subject' do
          put :update, params: { id: @subject.id, subject: @attrs }
        end

        it 'assigns the requested subject as @subject' do
          put :update, params: { id: @subject.id, subject: @attrs }
          expect(assigns(:subject)).to eq(@subject)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subject as @subject' do
          put :update, params: { id: @subject.id, subject: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested subject' do
          put :update, params: { id: @subject.id, subject: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @subject.id, subject: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subject as @subject' do
          put :update, params: { id: @subject.id, subject: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @subject = FactoryBot.create(:subject)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'destroys the requested subject' do
        delete :destroy, params: { id: @subject.id }
      end

      it 'redirects to the subjects list' do
        delete :destroy, params: { id: @subject.id }
        response.should redirect_to(subjects_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'destroys the requested subject' do
        delete :destroy, params: { id: @subject.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subject.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'destroys the requested subject' do
        delete :destroy, params: { id: @subject.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subject.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested subject' do
        delete :destroy, params: { id: @subject.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subject.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
