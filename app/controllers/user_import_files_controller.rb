class UserImportFilesController < ApplicationController
  before_action :set_user_import_file, only: [:show, :edit, :update, :destroy]
  before_filter :prepare_options, only: [:new, :edit]
  after_action :verify_authorized
  #after_action :verify_policy_scoped, :only => :index

  # GET /user_import_files
  def index
    authorize UserImportFile
    @user_import_files = UserImportFile.page(params[:page])
  end

  # GET /user_import_files/1
  def show
    if @user_import_file.user_import.path
      unless Setting.uploaded_file.storage == :s3
        file = @user_import_file.user_import.path
      end
    end

    respond_to do |format|
      format.html
      format.json
      format.download {
        if Setting.uploaded_file.storage == :s3
          redirect_to @user_import_file.user_import.expiring_url(10)
        else
          send_file file, :filename => @user_import_file.user_import_file_name, :type => 'application/octet-stream'
        end
      }
    end
  end

  # GET /user_import_files/new
  def new
    @user_import_file = UserImportFile.new
    authorize @user_import_file
  end

  # GET /user_import_files/1/edit
  def edit
  end

  # POST /user_import_files
  def create
    authorize UserImportFile
    @user_import_file = UserImportFile.new(user_import_file_params)
    @user_import_file.user = current_user

    if @user_import_file.save
      if @user_import_file.mode == 'import'
        Resque.enqueue(UserImportFileQueue, @user_import_file.id)
      end
      redirect_to @user_import_file, notice: t('import.successfully_created', model: t('activerecord.models.user_import_file'))
    else
      prepare_options
      render action: 'new'
    end
  end

  # PATCH/PUT /user_import_files/1
  def update
    if @user_import_file.update(user_import_file_params)
      if @user_import_file.mode == 'import'
        Resque.enqueue(UserImportFileQueue, @user_import_file.id)
      end
      redirect_to @user_import_file, notice: t('controller.successfully_updated', :model => t('activerecord.models.user_import_file'))
    else
      prepare_options
      render action: 'edit'
    end
  end

  # DELETE /user_import_files/1
  def destroy
    @user_import_file.destroy

    respond_to do |format|
      format.html { redirect_to user_import_files_url, notice: t('controller.successfully_destroyed', :model => t('activerecord.models.user_import_file')) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_import_file
      @user_import_file = UserImportFile.find(params[:id])
      authorize @user_import_file
    end

    # Only allow a trusted parameter "white list" through.
    def user_import_file_params
      params.require(:user_import_file).permit(
        :user_import, :edit_mode, :user_encoding, :mode,
	:default_user_group_id, :default_library_id
      )
    end

    def prepare_options
      @user_groups = UserGroup.all
      @libraries = Library.all
      if @user_import_file.new_record?
        @user_import_file.default_user_group = current_user.user_group
        @user_import_file.default_library = current_user.library
      end
    end
end
