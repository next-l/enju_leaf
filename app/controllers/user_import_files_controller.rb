class UserImportFilesController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, :only => :index
  before_action :set_user_import_file, only: [:show, :edit, :update, :destroy]

  # GET /user_import_files
  def index
    authorize UserImportFile
    @user_import_files = UserImportFile.page(params[:page])
  end

  # GET /user_import_files/1
  def show
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
      redirect_to @user_import_file, notice: 'User import file was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /user_import_files/1
  def update
    if @user_import_file.update(user_import_file_params)
      redirect_to @user_import_file, notice: 'User import file was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /user_import_files/1
  def destroy
    @user_import_file.destroy
    redirect_to user_import_files_url, notice: 'User import file was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_import_file
      @user_import_file = UserImportFile.find(params[:id])
      authorize @user_import_file
    end

    # Only allow a trusted parameter "white list" through.
    def user_import_file_params
      params.require(:user_import_file).permit(:user_id, :note, :executed_at, :state, :user_import_file_name, :user_import_content_type, :user_import_file_size, :user_import_updated_at, :user_import_fingerprint, :edit_mode, :error_message, [:user_import])
    end
end
