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

describe ContentTypesController do
  fixtures :all
  login_fixture_admin

  # This should return the minimal set of attributes required to create a valid
  # ContentType. As you add validations to ContentType, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    FactoryBot.attributes_for(:content_type)
  end

  describe 'GET index' do
    it 'assigns all content_types as @content_types' do
      content_type = ContentType.create! valid_attributes
      get :index
      expect(assigns(:content_types)).to eq(ContentType.order(:position))
    end
  end

  describe 'GET show' do
    it 'assigns the requested content_type as @content_type' do
      content_type = ContentType.create! valid_attributes
      get :show, params: { id: content_type.id }
      expect(assigns(:content_type)).to eq(content_type)
    end
  end

  describe 'GET new' do
    it 'assigns a new content_type as @content_type' do
      get :new
      expect(assigns(:content_type)).to be_a_new(ContentType)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested content_type as @content_type' do
      content_type = ContentType.create! valid_attributes
      get :edit, params: { id: content_type.id }
      expect(assigns(:content_type)).to eq(content_type)
    end

    it 'assigns the content_type even if it associates manifestation(s)' do
      content_type = FactoryBot.create(:content_type)
      manifestation = FactoryBot.create(:manifestation, content_type_id: content_type.id)
      get :edit, params: { id: content_type.id }
      expect(assigns(:content_type)).to eq content_type
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new ContentType' do
        expect do
          post :create, params: { content_type: valid_attributes }
        end.to change(ContentType, :count).by(1)
      end

      it 'assigns a newly created content_type as @content_type' do
        post :create, params: { content_type: valid_attributes }
        expect(assigns(:content_type)).to be_a(ContentType)
        expect(assigns(:content_type)).to be_persisted
      end

      it 'redirects to the created content_type' do
        post :create, params: { content_type: valid_attributes }
        expect(response).to redirect_to(ContentType.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved content_type as @content_type' do
        # Trigger the behavior that occurs when invalid params are submitted
        ContentType.any_instance.stub(:save).and_return(false)
        post :create, params: { content_type: { name: 'test' } }
        expect(assigns(:content_type)).to be_a_new(ContentType)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ContentType.any_instance.stub(:save).and_return(false)
        post :create, params: { content_type: { name: 'test' } }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested content_type' do
        content_type = ContentType.create! valid_attributes
        # Assuming there are no other content_types in the database, this
        # specifies that the ContentType created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        ContentType.any_instance.should_receive(:update).with('name' => 'test')
        put :update, params: { id: content_type.id, content_type: { 'name' => 'test' } }
      end

      it 'assigns the requested content_type as @content_type' do
        content_type = ContentType.create! valid_attributes
        put :update, params: { id: content_type.id, content_type: valid_attributes }
        expect(assigns(:content_type)).to eq(content_type)
      end

      it 'redirects to the content_type' do
        content_type = ContentType.create! valid_attributes
        put :update, params: { id: content_type.id, content_type: valid_attributes }
        expect(response).to redirect_to(content_type)
      end

      it 'moves its position when specified' do
        content_type = ContentType.create! valid_attributes
        position = content_type.position
        put :update, params: { id: content_type.id, move: 'higher' }
        expect(response).to redirect_to content_types_url
        assigns(:content_type).reload.position.should eq position - 1
      end
    end

    describe 'with invalid params' do
      it 'assigns the content_type as @content_type' do
        content_type = ContentType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ContentType.any_instance.stub(:save).and_return(false)
        put :update, params: { id: content_type.id, content_type: { name: 'test' } }
        expect(assigns(:content_type)).to eq(content_type)
      end

      it "re-renders the 'edit' template" do
        content_type = ContentType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ContentType.any_instance.stub(:save).and_return(false)
        put :update, params: { id: content_type.id, content_type: { name: 'test' } }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested content_type' do
      content_type = ContentType.create! valid_attributes
      expect do
        delete :destroy, params: { id: content_type.id }
      end.to change(ContentType, :count).by(-1)
    end

    it 'redirects to the content_types list' do
      content_type = ContentType.create! valid_attributes
      delete :destroy, params: { id: content_type.id }
      expect(response).to redirect_to(content_types_url)
    end
  end
end
