class ManifestationRelationshipsController < ApplicationController
  before_action :set_manifestation_relationship, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_manifestation
  before_action :prepare_options, only: [:new, :edit]

  # GET /manifestation_relationships
  # GET /manifestation_relationships.json
  def index
    case
    when @manifestation
      @manifestation_relationships = @manifestation.manifestation_relationships.order('manifestation_relationships.position').page(params[:page])
    else
      @manifestation_relationships = ManifestationRelationship.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /manifestation_relationships/1
  # GET /manifestation_relationships/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /manifestation_relationships/new
  def new
    if @manifestation.blank?
      redirect_to manifestations_url
      nil
    else
      @manifestation_relationship = ManifestationRelationship.new(
        parent: @manifestation,
        child: Manifestation.find(params[:child_id])
      )
    end
  end

  # GET /manifestation_relationships/1/edit
  def edit
  end

  # POST /manifestation_relationships
  # POST /manifestation_relationships.json
  def create
    @manifestation_relationship = ManifestationRelationship.new(manifestation_relationship_params)

    respond_to do |format|
      if @manifestation_relationship.save
        format.html { redirect_to @manifestation_relationship, notice: t('controller.successfully_created', model: t('activerecord.models.manifestation_relationship')) }
        format.json { render json: @manifestation_relationship, status: :created, location: @manifestation_relationship }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @manifestation_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_relationships/1
  # PUT /manifestation_relationships/1.json
  def update
    # 並べ替え
    if @manifestation && params[:move]
      move_position(@manifestation_relationship, params[:move], false)
      redirect_to manifestation_relationships_url(manifestation_id: @manifestation_relationship.parent_id)
      return
    end

    respond_to do |format|
      if @manifestation_relationship.update(manifestation_relationship_params)
        format.html { redirect_to @manifestation_relationship, notice: t('controller.successfully_updated', model: t('activerecord.models.manifestation_relationship')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @manifestation_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_relationships/1
  # DELETE /manifestation_relationships/1.json
  def destroy
    @manifestation_relationship.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.manifestation_relationship'))
        if @manifestation
          redirect_to manifestations_url(manifestation_id: @manifestation.id)
        else
          redirect_to manifestation_relationships_url
        end
      }
      format.json { head :no_content }
    end
  end

  private
  def set_manifestation_relationship
    @manifestation_relationship = ManifestationRelationship.find(params[:id])
    authorize @manifestation_relationship
  end

  def check_policy
    authorize ManifestationRelationship
  end

  def manifestation_relationship_params
    params.require(:manifestation_relationship).permit(
      :parent_id, :child_id, :manifestation_relationship_type_id
    )
  end

  def prepare_options
    @manifestation_relationship_types = ManifestationRelationshipType.all
  end
end
