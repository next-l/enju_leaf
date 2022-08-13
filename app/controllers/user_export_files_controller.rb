class UserExportFilesController < ApplicationController
  before_action :set_user_export_file, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /user_export_files
  # GET /user_export_files.json
  def index
    @user_export_files = UserExportFile.order('id DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /user_export_files/1
  # GET /user_export_files/1.json
  def show
    if @user_export_file.user_export.path
      unless ENV['ENJU_STORAGE'] == 's3'
        file = File.expand_path(@user_export_file.user_export.path)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.download {
        if ENV['ENJU_STORAGE'] == 's3'
          send_data Faraday.get(@user_export_file.user_export.expiring_url).body.force_encoding('UTF-8'),
            filename: File.basename(@user_export_file.user_export_file_name), type: 'application/octet-stream'
        else
          send_file file, filename: File.basename(@user_export_file.user_export_file_name), type: 'application/octet-stream'
        end
      }
    end
  end

  # GET /user_export_files/new
  def new
    @user_export_file = UserExportFile.new
    @user_export_file.user = current_user
  end

  # GET /user_export_files/1/edit
  def edit
  end

  # POST /user_export_files
  # POST /user_export_files.json
  def create
    @user_export_file = UserExportFile.new(user_export_file_params)
    @user_export_file.user = current_user

    respond_to do |format|
      if @user_export_file.save
        if @user_export_file.mode == 'export'
          UserExportFileJob.perform_later(@user_export_file)
        end
        format.html { redirect_to @user_export_file, notice: t('export.successfully_created', model: t('activerecord.models.user_export_file')) }
        format.json { render json: @user_export_file, status: :created, location: @user_export_file }
      else
        format.html { render action: "new" }
        format.json { render json: @user_export_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_export_files/1
  # PUT /user_export_files/1.json
  def update
    respond_to do |format|
      if @user_export_file.update(user_export_file_params)
        if @user_export_file.mode == 'export'
          UserExportFileJob.perform_later(@user_export_file)
        end
        format.html { redirect_to @user_export_file, notice: t('controller.successfully_updated', model: t('activerecord.models.user_export_file')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_export_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_export_files/1
  # DELETE /user_export_files/1.json
  def destroy
    @user_export_file.destroy

    respond_to do |format|
      format.html { redirect_to user_export_files_url }
      format.json { head :no_content }
    end
  end

  private

  def set_user_export_file
    @user_export_file = UserExportFile.find(params[:id])
    authorize @user_export_file
  end

  def check_policy
    authorize UserExportFile
  end

  def user_export_file_params
    params.require(:user_export_file).permit(:mode)
  end
end
