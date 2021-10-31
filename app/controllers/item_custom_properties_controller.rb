class ItemCustomPropertiesController < ApplicationController
  before_action :set_item_custom_property, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create ]

  # GET /item_custom_properties
  def index
    @item_custom_properties = ItemCustomProperty.order(:position)
  end

  # GET /item_custom_properties/1
  def show
  end

  # GET /item_custom_properties/new
  def new
    @item_custom_property = ItemCustomProperty.new
  end

  # GET /item_custom_properties/1/edit
  def edit
  end

  # POST /item_custom_properties
  def create
    @item_custom_property = ItemCustomProperty.new(item_custom_property_params)

    if @item_custom_property.save
      redirect_to @item_custom_property, notice: t('controller.successfully_created', model: t('activerecord.models.item_custom_property'))
    else
      render :new
    end
  end

  # PATCH/PUT /item_custom_properties/1
  def update
    if params[:move]
      move_position(@item_custom_property, params[:move])
      return
    end

    if @item_custom_property.update(item_custom_property_params)
      redirect_to @item_custom_property, notice: t('controller.successfully_updated', model: t('activerecord.models.item_custom_property'))
    else
      render :edit
    end
  end

  # DELETE /item_custom_properties/1
  def destroy
    @item_custom_property.destroy
    redirect_to item_custom_properties_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.item_custom_property'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_custom_property
      @item_custom_property = ItemCustomProperty.find(params[:id])
      authorize @item_custom_property
    end

    def check_policy
      authorize ItemCustomProperty
    end

    # Only allow a trusted parameter "white list" through.
    def item_custom_property_params
      params.require(:item_custom_property).permit(:name, :display_name, :note)
    end
end
