class RequestStatusTypesController < ApplicationController
  before_action :set_request_status_type, only: [:show, :edit, :update]
  before_action :check_policy, only: [:index]

  # GET /request_status_types
  def index
    @request_status_types = RequestStatusType.order(:position)
  end

  # GET /request_status_types/1
  def show
  end

  # GET /request_status_types/1/edit
  def edit
  end

  # PUT /request_status_types/1
  def update
    if params[:move]
      move_position(@request_status_type, params[:move])
      return
    end

    respond_to do |format|
      if @request_status_type.update(request_status_type_params)
        format.html { redirect_to @request_status_type, notice: t('controller.successfully_updated', model: t('activerecord.models.request_status_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  private

  def set_request_status_type
    @request_status_type = RequestStatusType.find(params[:id])
    authorize @request_status_type
  end

  def check_policy
    authorize RequestStatusType
  end

  def request_status_type_params
    params.require(:request_status_type).permit(:name, :display_name, :note)
  end
end
