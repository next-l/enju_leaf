class UserExportFilesController < ApplicationController
  before_action :set_user_export_file, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized

  # GET /user_export_files
  def index
    authorize UserExportFile
    @user_export_files = UserExportFile.order('id DESC').page(params[:page])
  end

  # GET /user_export_files/1
  def show
  end

  # GET /user_export_files/new
  def new
    @user_export_file = UserExportFile.new
    @user_export_file.user = current_user
    authorize @user_export_file
  end

  # GET /user_export_files/1/edit
  def edit
  end

  # POST /user_export_files
  def create
    authorize UserExportFile
    @user_export_file = UserExportFile.new(user_export_file_params)
    @user_export_file.user = current_user
    if @user_export_file.save
      if @user_export_file.mode == 'export'
        Resque.enqueue(UserExportFileQueue, @user_export_file.id)
      end
      redirect_to @user_export_file, notice: t('export.user_export_task_created')
    else
      render :new
    end
  end

  # PATCH/PUT /user_export_files/1
  def update
    if @user_export_file.update(user_export_file_params)
      redirect_to @user_export_file, notice: t('controller.successfully_updated', :model => t('activerecord.models.user_export_file'))
    else
      render :edit
    end
  end

  # DELETE /user_export_files/1
  def destroy
    @user_export_file.destroy
    redirect_to user_export_files_url, notice: t('controller.successfully_destroyed', :model => t('activerecord.models.user_export_file'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_export_file
      @user_export_file = UserExportFile.find(params[:id])
      authorize @user_export_file
    end

    # Only allow a trusted parameter "white list" through.
    def user_export_file_params
      params.require(:user_export_file).permit(:user_id, :mode)
    end
end
