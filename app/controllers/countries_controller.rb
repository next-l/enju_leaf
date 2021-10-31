class CountriesController < ApplicationController
  before_action :set_country, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /countries
  # GET /countries.json
  def index
    @countries = Country.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @countries }
    end
  end

  # GET /countries/1
  # GET /countries/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @country }
    end
  end

  # GET /countries/new
  # GET /countries/new.json
  def new
    @country = Country.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @country }
    end
  end

  # GET /countries/1/edit
  def edit
  end

  # POST /countries
  # POST /countries.json
  def create
    @country = Country.new(country_params)

    respond_to do |format|
      if @country.save
        format.html { redirect_to @country, notice: t('controller.successfully_created', model: t('activerecord.models.country')) }
        format.json { render json: @country, status: :created, location: @country }
      else
        format.html { render action: "new" }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /countries/1
  # PUT /countries/1.json
  def update
    if params[:move]
      move_position(@country, params[:move])
      return
    end

    respond_to do |format|
      if @country.update(country_params)
        format.html { redirect_to @country, notice: t('controller.successfully_updated', model: t('activerecord.models.country')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /countries/1
  # DELETE /countries/1.json
  def destroy
    @country.destroy

    respond_to do |format|
      format.html { redirect_to countries_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.country')) }
      format.json { head :no_content }
    end
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
