class LanguagesController < ApplicationController
  before_action :set_language, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /languages
  def index
    @languages = Language.page(params[:page])
  end

  # GET /languages/1
  def show
  end

  # GET /languages/new
  def new
    @language = Language.new
  end

  # GET /languages/1/edit
  def edit
  end

  # POST /languages
  def create
    @language = Language.new(language_params)

    respond_to do |format|
      if @language.save
        format.html { redirect_to @language, notice: t('controller.successfully_created', model: t('activerecord.models.language')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /languages/1
  def update
    if params[:move]
      move_position(@language, params[:move])
      return
    end

    respond_to do |format|
      if @language.update(language_params)
        format.html { redirect_to @language, notice: t('controller.successfully_updated', model: t('activerecord.models.language')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /languages/1
  def destroy
    @language.destroy
    redirect_to languages_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.language'))
  end

  private
  def set_language
    @language = Language.find(params[:id])
    authorize @language
  end

  def check_policy
    authorize Language
  end

  def language_params
    params.require(:language).permit(
      :name, :native_name, :display_name, :iso_639_1, :iso_639_2, :iso_639_3,
      :note
    )
  end
end
