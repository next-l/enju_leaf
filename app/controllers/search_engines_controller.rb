class SearchEnginesController < ApplicationController
  before_action :set_search_engine, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /search_engines
  # GET /search_engines.json
  def index
    @search_engines = SearchEngine.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @search_engines }
    end
  end

  # GET /search_engines/1
  # GET /search_engines/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @search_engine }
    end
  end

  # GET /search_engines/new
  # GET /search_engines/new.json
  def new
    @search_engine = SearchEngine.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @search_engine }
    end
  end

  # GET /search_engines/1/edit
  def edit
  end

  # POST /search_engines
  # POST /search_engines.json
  def create
    @search_engine = SearchEngine.new(search_engine_params)

    respond_to do |format|
      if @search_engine.save
        format.html { redirect_to @search_engine, notice: t('controller.successfully_created', model: t('activerecord.models.search_engine')) }
        format.json { render json: @search_engine, status: :created, location: @search_engine }
      else
        format.html { render action: "new" }
        format.json { render json: @search_engine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /search_engines/1
  # PUT /search_engines/1.json
  def update
    if params[:move]
      move_position(@search_engine, params[:move])
      return
    end

    respond_to do |format|
      if @search_engine.update(search_engine_params)
        format.html { redirect_to @search_engine, notice: t('controller.successfully_updated', model: t('activerecord.models.search_engine')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @search_engine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /search_engines/1
  # DELETE /search_engines/1.json
  def destroy
    @search_engine.destroy

    respond_to do |format|
      format.html { redirect_to search_engines_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.search_engine')) }
      format.json { head :no_content }
    end
  end

  private

  def set_search_engine
    @search_engine = SearchEngine.find(params[:id])
    authorize @search_engine
  end

  def check_policy
    authorize SearchEngine
  end

  def search_engine_params
    params.require(:search_engine).permit(
      :name, :display_name, :url, :base_url, :http_method,
      :query_param, :additional_param, :note
    )
  end
end
