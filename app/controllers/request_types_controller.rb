class RequestTypesController < ApplicationController
  before_action :set_request_type, only: [:show, :edit, :update]
  before_action :check_policy, only: [:index]

  # GET /request_types
  def index
    @request_types = RequestType.order(:position)
  end

  # GET /request_types/1
  def show
  end

  # GET /request_types/1/edit
  def edit
  end

  # PUT /request_types/1
  def update
    if params[:move]
      move_position(@request_type, params[:move])
      return
    end

    respond_to do |format|
      if @request_type.update(request_type_params)
        format.html { redirect_to @request_type, notice: t('controller.successfully_updated', model: t('activerecord.models.request_type')) }
      else
        format.html { render action: "edit" }
      end
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
