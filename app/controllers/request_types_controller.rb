class RequestTypesController < ApplicationController
  before_action :set_request_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /request_types
  # GET /request_types.json
  def index
    @request_types = RequestType.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @request_types }
    end
  end

  # GET /request_types/1
  # GET /request_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request_type }
    end
  end

  # GET /request_types/new
  # GET /request_types/new.json
  def new
    @request_type = RequestType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request_type }
    end
  end

  # GET /request_types/1/edit
  def edit
  end

  # POST /request_types
  # POST /request_types.json
  def create
    @request_type = RequestType.new(request_type_params)

    respond_to do |format|
      if @request_type.save
        format.html { redirect_to @request_type, notice: t('controller.successfully_created', model: t('activerecord.models.request_type')) }
        format.json { render json: @request_type, status: :created, location: @request_type }
      else
        format.html { render action: "new" }
        format.json { render json: @request_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /request_types/1
  # PUT /request_types/1.json
  def update
    if params[:move]
      move_position(@request_type, params[:move])
      return
    end

    respond_to do |format|
      if @request_type.update(request_type_params)
        format.html { redirect_to @request_type, notice: t('controller.successfully_updated', model: t('activerecord.models.request_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @request_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_types/1
  # DELETE /request_types/1.json
  def destroy
    @request_type.destroy

    respond_to do |format|
      format.html { redirect_to request_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.request_type')) }
      format.json { head :no_content }
    end
  end

  private

  def set_request_type
    @request_type = RequestType.find(params[:id])
    authorize @request_type
  end

  def check_policy
    authorize RequestType
  end

  def request_type_params
    params.require(:request_type).permit(:name, :display_name, :note)
  end
end
