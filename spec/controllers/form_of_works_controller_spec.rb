require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe FormOfWorksController do
  fixtures :all
  login_fixture_admin

  # This should return the minimal set of attributes required to create a valid
  # FormOfWork. As you add validations to FormOfWork, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    FactoryBot.attributes_for(:form_of_work)
  end

  describe 'GET index' do
    it 'assigns all form_of_works as @form_of_works' do
      form_of_work = FormOfWork.create! valid_attributes
      get :index
      expect(assigns(:form_of_works)).to eq(FormOfWork.order(:position))
    end
  end

  describe 'GET show' do
    it 'assigns the requested form_of_work as @form_of_work' do
      form_of_work = FormOfWork.create! valid_attributes
      get :show, params: { id: form_of_work.id }
      expect(assigns(:form_of_work)).to eq(form_of_work)
    end
  end

  describe 'GET new' do
    it 'assigns a new form_of_work as @form_of_work' do
      get :new
      expect(assigns(:form_of_work)).to be_a_new(FormOfWork)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested form_of_work as @form_of_work' do
      form_of_work = FormOfWork.create! valid_attributes
      get :edit, params: { id: form_of_work.id }
      expect(assigns(:form_of_work)).to eq(form_of_work)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new FormOfWork' do
        expect do
          post :create, params: { form_of_work: valid_attributes }
        end.to change(FormOfWork, :count).by(1)
      end

      it 'assigns a newly created form_of_work as @form_of_work' do
        post :create, params: { form_of_work: valid_attributes }
        expect(assigns(:form_of_work)).to be_a(FormOfWork)
        expect(assigns(:form_of_work)).to be_persisted
      end

      it 'redirects to the created form_of_work' do
        post :create, params: { form_of_work: valid_attributes }
        expect(response).to redirect_to(FormOfWork.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved form_of_work as @form_of_work' do
        # Trigger the behavior that occurs when invalid params are submitted
        FormOfWork.any_instance.stub(:save).and_return(false)
        post :create, params: { form_of_work: { name: 'test' } }
        expect(assigns(:form_of_work)).to be_a_new(FormOfWork)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        FormOfWork.any_instance.stub(:save).and_return(false)
        post :create, params: { form_of_work: { name: 'test' } }
        # expect(response).to render_template("new")
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested form_of_work' do
        form_of_work = FormOfWork.create! valid_attributes
        # Assuming there are no other form_of_works in the database, this
        # specifies that the FormOfWork created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        # FormOfWork.any_instance.should_receive(:update).with('name' => 'test')
        put :update, params: { id: form_of_work.id, form_of_work: { 'name' => 'test' } }
      end

      it 'assigns the requested form_of_work as @form_of_work' do
        form_of_work = FormOfWork.create! valid_attributes
        put :update, params: { id: form_of_work.id, form_of_work: valid_attributes }
        expect(assigns(:form_of_work)).to eq(form_of_work)
      end

      it 'redirects to the form_of_work' do
        form_of_work = FormOfWork.create! valid_attributes
        put :update, params: { id: form_of_work.id, form_of_work: valid_attributes }
        expect(response).to redirect_to(form_of_work)
      end

      it 'moves its position when specified' do
        form_of_work = FormOfWork.create! valid_attributes
        position = form_of_work.position
        put :update, params: { id: form_of_work.id, move: 'higher' }
        expect(response).to redirect_to form_of_works_url
        form_of_work.reload
        form_of_work.position.should eq position - 1
      end
    end

    describe 'with invalid params' do
      it 'assigns the form_of_work as @form_of_work' do
        form_of_work = FormOfWork.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        FormOfWork.any_instance.stub(:save).and_return(false)
        put :update, params: { id: form_of_work.id, form_of_work: { name: 'test' } }
        expect(assigns(:form_of_work)).to eq(form_of_work)
      end

      it "re-renders the 'edit' template" do
        form_of_work = FormOfWork.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        FormOfWork.any_instance.stub(:save).and_return(false)
        put :update, params: { id: form_of_work.id, form_of_work: { name: 'test' } }
        # expect(response).to render_template("edit")
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested form_of_work' do
      form_of_work = FormOfWork.create! valid_attributes
      expect do
        delete :destroy, params: { id: form_of_work.id }
      end.to change(FormOfWork, :count).by(-1)
    end

    it 'redirects to the form_of_works list' do
      form_of_work = FormOfWork.create! valid_attributes
      delete :destroy, params: { id: form_of_work.id }
      expect(response).to redirect_to(form_of_works_url)
    end
  end
end
