class SearchEnginesController < ApplicationController
  before_action :set_search_engine, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /search_engines
  def index
    @search_engines = SearchEngine.order(:position)
  end

  # GET /search_engines/1
  def show
  end

  # GET /search_engines/new
  def new
    @search_engine = SearchEngine.new
  end

  # GET /search_engines/1/edit
  def edit
  end

  # POST /search_engines
  def create
    @search_engine = SearchEngine.new(search_engine_params)

    respond_to do |format|
      if @search_engine.save
        format.html { redirect_to @search_engine, notice: t('controller.successfully_created', model: t('activerecord.models.search_engine')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /search_engines/1
  def update
    if params[:move]
      move_position(@search_engine, params[:move])
      return
    end

    respond_to do |format|
      if @search_engine.update(search_engine_params)
        format.html { redirect_to @search_engine, notice: t('controller.successfully_updated', model: t('activerecord.models.search_engine')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /search_engines/1
  def destroy
    @search_engine.destroy
    redirect_to search_engines_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.search_engine'))
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
