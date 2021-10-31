class CreateTypesController < ApplicationController
  before_action :set_create_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /create_types
  # GET /create_types.json
  def index
    @create_types = CreateType.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @create_types }
    end
  end

  # GET /create_types/1
  # GET /create_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @create_type }
    end
  end

  # GET /create_types/new
  # GET /create_types/new.json
  def new
    @create_type = CreateType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @create_type }
    end
  end

  # GET /create_types/1/edit
  def edit
  end

  # POST /create_types
  # POST /create_types.json
  def create
    @create_type = CreateType.new(create_type_params)

    respond_to do |format|
      if @create_type.save
        format.html { redirect_to @create_type, notice: t('controller.successfully_created', model: t('activerecord.models.create_type')) }
        format.json { render json: @create_type, status: :created, location: @create_type }
      else
        format.html { render action: "new" }
        format.json { render json: @create_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /create_types/1
  # PUT /create_types/1.json
  def update
    if params[:move]
      move_position(@create_type, params[:move])
      return
    end

    respond_to do |format|
      if @create_type.update(create_type_params)
        format.html { redirect_to @create_type, notice: t('controller.successfully_updated', model: t('activerecord.models.create_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @create_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /create_types/1
  # DELETE /create_types/1.json
  def destroy
    @create_type.destroy

    respond_to do |format|
      format.html { redirect_to create_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.create_type')) }
      format.json { head :no_content }
    end
  end

  private
  def set_create_type
    @create_type = CreateType.find(params[:id])
    authorize @create_type
  end

  def check_policy
    authorize CreateType
  end

  def create_type_params
    params.require(:create_type).permit(:name, :display_name, :note, :position)
  end
end
