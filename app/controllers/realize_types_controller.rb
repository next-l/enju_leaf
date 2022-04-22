class RealizeTypesController < ApplicationController
  before_action :set_realize_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /realize_types
  # GET /realize_types.json
  def index
    @realize_types = RealizeType.order(:position)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /realize_types/1
  # GET /realize_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /realize_types/new
  def new
    @realize_type = RealizeType.new
  end

  # GET /realize_types/1/edit
  def edit
  end

  # POST /realize_types
  # POST /realize_types.json
  def create
    @realize_type = RealizeType.new(realize_type_params)

    respond_to do |format|
      if @realize_type.save
        format.html { redirect_to @realize_type, notice: t('controller.successfully_created', model: t('activerecord.models.realize_type')) }
        format.json { render json: @realize_type, status: :created, location: @realize_type }
      else
        format.html { render action: "new" }
        format.json { render json: @realize_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /realize_types/1
  # PUT /realize_types/1.json
  def update
    if params[:move]
      move_position(@realize_type, params[:move])
      return
    end

    respond_to do |format|
      if @realize_type.update(realize_type_params)
        format.html { redirect_to @realize_type, notice: t('controller.successfully_updated', model: t('activerecord.models.realize_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @realize_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /realize_types/1
  # DELETE /realize_types/1.json
  def destroy
    @realize_type.destroy

    respond_to do |format|
      format.html { redirect_to realize_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.realize_type')) }
      format.json { head :no_content }
    end
  end

  private
  def set_realize_type
    @realize_type = RealizeType.find(params[:id])
    authorize @realize_type
  end

  def check_policy
    authorize RealizeType
  end

  def realize_type_params
    params.require(:realize_type).permit(
      :name, :display_name, :note, :position
    )
  end
end
