class CirculationStatusesController < ApplicationController
  before_action :set_circulation_status, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /circulation_statuses
  def index
    @circulation_statuses = CirculationStatus.order(:position)
  end

  # GET /circulation_statuses/1
  def show
  end

  # GET /circulation_statuses/new
  def new
    @circulation_status = CirculationStatus.new
  end

  # GET /circulation_statuses/1/edit
  def edit
  end

  # POST /circulation_statuses
  def create
    @circulation_status = CirculationStatus.new(circulation_status_params)

    respond_to do |format|
      if @circulation_status.save
        format.html { redirect_to @circulation_status, notice: t('controller.successfully_created', model: t('activerecord.models.circulation_status')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /circulation_statuses/1
  def update
    if params[:move]
      move_position(@circulation_status, params[:move])
      return
    end

    respond_to do |format|
      if @circulation_status.update(circulation_status_params)
        format.html { redirect_to @circulation_status, notice: t('controller.successfully_updated', model: t('activerecord.models.circulation_status')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /circulation_statuses/1
  def destroy
    @circulation_status.destroy
    redirect_to circulation_statuses_url
  end

  private

  def set_circulation_status
    @circulation_status = CirculationStatus.find(params[:id])
    authorize @circulation_status
  end

  def check_policy
    authorize CirculationStatus
  end

  def circulation_status_params
    params.require(:circulation_status).permit(:name, :display_name, :note)
  end
end
