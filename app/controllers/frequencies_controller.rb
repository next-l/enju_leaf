class FrequenciesController < ApplicationController
  before_action :set_frequency, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /frequencies
  def index
    @frequencies = Frequency.order(:position)
  end

  # GET /frequencies/1
  def show
  end

  # GET /frequencies/new
  def new
    @frequency = Frequency.new
  end

  # GET /frequencies/1/edit
  def edit
  end

  # POST /frequencies
  def create
    @frequency = Frequency.new(frequency_params)

    respond_to do |format|
      if @frequency.save
        format.html { redirect_to @frequency, notice: t('controller.successfully_created', model: t('activerecord.models.frequency')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /frequencies/1
  def update
    if params[:move]
      move_position(@frequency, params[:move])
      return
    end

    respond_to do |format|
      if @frequency.update(frequency_params)
        format.html { redirect_to @frequency, notice: t('controller.successfully_updated', model: t('activerecord.models.frequency')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /frequencies/1
  def destroy
    @frequency.destroy
    redirect_to frequencies_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.frequency'))
  end

  private

  def set_frequency
    @frequency = Frequency.find(params[:id])
    authorize @frequency
  end

  def check_policy
    authorize Frequency
  end

  def frequency_params
    params.require(:frequency).permit(:name, :display_name, :note)
  end
end
