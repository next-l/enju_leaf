class CountriesController < ApplicationController
  before_action :set_country, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /countries
  def index
    @countries = Country.page(params[:page])
  end

  # GET /countries/1
  def show
  end

  # GET /countries/new
  def new
    @country = Country.new
  end

  # GET /countries/1/edit
  def edit
  end

  # POST /countries
  def create
    @country = Country.new(country_params)

    respond_to do |format|
      if @country.save
        format.html { redirect_to @country, notice: t('controller.successfully_created', model: t('activerecord.models.country')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /countries/1
  def update
    if params[:move]
      move_position(@country, params[:move])
      return
    end

    respond_to do |format|
      if @country.update(country_params)
        format.html { redirect_to @country, notice: t('controller.successfully_updated', model: t('activerecord.models.country')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /countries/1
  def destroy
    @country.destroy
    redirect_to countries_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.country'))
  end

  private
  def set_country
    @country = Country.find(params[:id])
    authorize @country
  end

  def check_policy
    authorize Country
  end

  def country_params
    params.require(:country).permit(
      :name, :display_name, :alpha_2, :alpha_3, :numeric_3, :note
    )
  end
end
