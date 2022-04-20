class ManifestationRelationshipTypesController < ApplicationController
  before_action :set_manifestation_relationship_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /manifestation_relationship_types
  def index
    @manifestation_relationship_types = ManifestationRelationshipType.all
  end

  # GET /manifestation_relationship_types/1
  def show
  end

  # GET /manifestation_relationship_types/new
  def new
    @manifestation_relationship_type = ManifestationRelationshipType.new
  end

  # GET /manifestation_relationship_types/1/edit
  def edit
  end

  # POST /manifestation_relationship_types
  def create
    @manifestation_relationship_type = ManifestationRelationshipType.new(manifestation_relationship_type_params)

    respond_to do |format|
      if @manifestation_relationship_type.save
        format.html { redirect_to @manifestation_relationship_type, notice: t('controller.successfully_created', model: t('activerecord.models.manifestation_relationship_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /manifestation_relationship_types/1
  def update
    if params[:move]
      move_position(@manifestation_relationship_type, params[:move])
      return
    end

    respond_to do |format|
      if @manifestation_relationship_type.update(manifestation_relationship_type_params)
        format.html { redirect_to @manifestation_relationship_type, notice: t('controller.successfully_updated', model: t('activerecord.models.manifestation_relationship_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /manifestation_relationship_types/1
  def destroy
    @manifestation_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to manifestation_relationship_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.manifestation_relationship_type')) }
    end
  end

  private
  def set_manifestation_relationship_type
    @manifestation_relationship_type = ManifestationRelationshipType.find(params[:id])
    authorize @manifestation_relationship_type
  end

  def check_policy
    authorize ManifestationRelationshipType
  end

  def manifestation_relationship_type_params
    params.require(:manifestation_relationship_type).permit(
      :name, :display_name, :note
    )
  end
end
