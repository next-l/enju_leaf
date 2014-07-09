class UserExportFilesController < ApplicationController
  load_and_authorize_user

  # GET /user_export_files
  # GET /user_export_files.json
  def index
    @user_export_files = UserExportFile.order('id DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @user_export_files }
    end
  end

  # GET /user_export_files/1
  # GET /user_export_files/1.json
  def show
    if @user_export_file.user_export.path
      unless Setting.uploaded_file.storage == :s3
        file = @user_export_file.user_export.path
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user_export_file }
      format.download {
        if Setting.uploaded_file.storage == :s3
          redirect_to @user_export_file.user_export.expiring_url(10)
        else
          send_file file, :filename => @user_export_file.user_export_file_name, :type => 'application/octet-stream'
        end
      }
    end
  end

  # GET /user_export_files/new
  # GET /user_export_files/new.json
  def new
    @user_export_file = UserExportFile.new
    @user_export_file.user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user_export_file }
    end
  end

  # GET /user_export_files/1/edit
  def edit
  end

  # POST /user_export_files
  # POST /user_export_files.json
  def create
    @user_export_file = UserExportFile.new(params[:user_export_file])
    @user_export_file.user = current_user

    respond_to do |format|
      if @user_export_file.save
        if @user_export_file.mode == 'export'
          Resque.enqueue(UserExportFileQueue, @user_export_file.id)
        end
        format.html { redirect_to @user_export_file, :notice => t('controller.successfully_created', :model => t('activerecord.models.user_export_file')) }
        format.json { render :json => @user_export_file, :status => :created, :location => @user_export_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user_export_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_export_files/1
  # PUT /user_export_files/1.json
  def update
    respond_to do |format|
      if @user_export_file.update_attributes(params[:user_export_file])
        if @user_export_file.mode == 'export'
          UserExportFileQueue.perform(@user_export_file.id)
        end
        format.html { redirect_to @user_export_file, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user_export_file')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user_export_file.errors, :status => :unprocessable_entity }
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
end
