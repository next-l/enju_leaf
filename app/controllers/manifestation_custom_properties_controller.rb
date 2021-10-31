class ManifestationCustomPropertiesController < ApplicationController
  before_action :set_manifestation_custom_property, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create ]

  # GET /manifestation_custom_properties
  def index
    @manifestation_custom_properties = ManifestationCustomProperty.order(:position)
  end

  # GET /manifestation_custom_properties/1
  def show
  end

  # GET /manifestation_custom_properties/new
  def new
    @manifestation_custom_property = ManifestationCustomProperty.new
  end

  # GET /manifestation_custom_properties/1/edit
  def edit
  end

  # POST /manifestation_custom_properties
  def create
    @manifestation_custom_property = ManifestationCustomProperty.new(manifestation_custom_property_params)

    if @manifestation_custom_property.save
      redirect_to @manifestation_custom_property, notice: t('controller.successfully_created', model: t('activerecord.models.manifestation_custom_property'))
    else
      render :new
    end
  end

  # PATCH/PUT /manifestation_custom_properties/1
  def update
    if params[:move]
      move_position(@manifestation_custom_property, params[:move])
      return
    end

    if @manifestation_custom_property.update(manifestation_custom_property_params)
      redirect_to @manifestation_custom_property, notice: t('controller.successfully_updated', model: t('activerecord.models.manifestation_custom_property'))
    else
      render :edit
    end
  end

  # DELETE /manifestation_custom_properties/1
  def destroy
    @manifestation_custom_property.destroy
    redirect_to manifestation_custom_properties_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.manifestation_custom_property'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manifestation_custom_property
      @manifestation_custom_property = ManifestationCustomProperty.find(params[:id])
      authorize @manifestation_custom_property
    end

    def check_policy
      authorize ManifestationCustomProperty
    end

    # Only allow a trusted parameter "white list" through.
    def manifestation_custom_property_params
      params.require(:manifestation_custom_property).permit(:name, :display_name, :note)
    end
end
