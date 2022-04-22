class ResourceImportFilesController < ApplicationController
  before_action :set_resource_import_file, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :prepare_options, only: [:new, :edit]

  # GET /resource_import_files
  # GET /resource_import_files.json
  def index
    @resource_import_files = ResourceImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /resource_import_files/1
  # GET /resource_import_files/1.json
  def show
    if @resource_import_file.resource_import.path
      unless ENV['ENJU_STORAGE'] == 's3'
        file = File.expand_path(@resource_import_file.resource_import.path)
      end
    end
    @resource_import_results = @resource_import_file.resource_import_results.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.download {
        if ENV['ENJU_STORAGE'] == 's3'
          redirect_to URI.parse(@resource_import_file.resource_import.expiring_url(10)).to_s
        else
          send_file file, filename: File.basename(@resource_import_file.resource_import_file_name), type: 'application/octet-stream'
        end
      }
    end
  end

  # GET /resource_import_files/new
  def new
    @resource_import_file = ResourceImportFile.new
    @resource_import_file.library_id = current_user.profile.library_id
  end

  # GET /resource_import_files/1/edit
  def edit
  end

  # POST /resource_import_files
  # POST /resource_import_files.json
  def create
    @resource_import_file = ResourceImportFile.new(resource_import_file_params)
    @resource_import_file.user = current_user

    respond_to do |format|
      if @resource_import_file.save
        if @resource_import_file.mode == 'import'
          ResourceImportFileJob.perform_later(@resource_import_file)
        end
        format.html { redirect_to @resource_import_file, notice: t('import.successfully_created', model: t('activerecord.models.resource_import_file')) }
        format.json { render json: @resource_import_file, status: :created, location: @resource_import_file }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @resource_import_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource_import_files/1
  # PUT /resource_import_files/1.json
  def update
    respond_to do |format|
      if @resource_import_file.update(resource_import_file_params)
        if @resource_import_file.mode == 'import'
          ResourceImportFileJob.perform_later(@resource_import_file)
        end
        format.html { redirect_to @resource_import_file, notice: t('controller.successfully_updated', model: t('activerecord.models.resource_import_file')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @resource_import_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_import_files/1
  # DELETE /resource_import_files/1.json
  def destroy
    @resource_import_file.destroy

    respond_to do |format|
      format.html { redirect_to resource_import_files_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.resource_import_file')) }
      format.json { head :no_content }
    end
  end

  private
  def set_resource_import_file
    @resource_import_file = ResourceImportFile.find(params[:id])
    authorize @resource_import_file
  end

  def check_policy
    authorize ResourceImportFile
  end

  def resource_import_file_params
    params.require(:resource_import_file).permit(
      :resource_import, :edit_mode, :user_encoding, :mode,
      :default_shelf_id, :library_id
    )
  end

  def prepare_options
    @libraries = Library.all
    library = Library.where(id: @resource_import_file.try(:library_id)).first
    if library
      @shelves = library.shelves
    else
      @shelves = current_user.profile.library.try(:shelves)
    end
  end
end
