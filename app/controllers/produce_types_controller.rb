class ProduceTypesController < ApplicationController
  before_action :set_produce_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /produce_types
  def index
    @produce_types = ProduceType.order(:position)
  end

  # GET /produce_types/1
  def show
  end

  # GET /produce_types/new
  def new
    @produce_type = ProduceType.new
  end

  # GET /produce_types/1/edit
  def edit
  end

  # POST /produce_types
  def create
    @produce_type = ProduceType.new(produce_type_params)

    respond_to do |format|
      if @produce_type.save
        format.html { redirect_to @produce_type, notice: t('controller.successfully_created', model: t('activerecord.models.produce_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /produce_types/1
  def update
    if params[:move]
      move_position(@produce_type, params[:move])
      return
    end

    respond_to do |format|
      if @produce_type.update(produce_type_params)
        format.html { redirect_to @produce_type, notice: t('controller.successfully_updated', model: t('activerecord.models.produce_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /produce_types/1
  def destroy
    @produce_type.destroy

    respond_to do |format|
      format.html { redirect_to produce_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.produce_type')) }
    end
  end

  private
  def set_produce_type
    @produce_type = ProduceType.find(params[:id])
    authorize @produce_type
  end

  def check_policy
    authorize ProduceType
  end

  def produce_type_params
    params.require(:produce_type).permit(:name, :display_name, :note, :position)
  end
end
