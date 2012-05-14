class LibcheckDataFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @libcheck_data_files = LibcheckDataFile.find(:all, :conditions => ["library_check_id = ?", params[:library_check_id]])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @libcheck_data_file }
    end
  end

  # GET /libcheck_data_files/new
  # GET /libcheck_data_files/new.json
  def new
    @libcheck_data_file = LibcheckDataFile.new
    @libcheck_data_file.library_check_id = params[:library_check_id]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @libcheck_data_file }
    end
  end

  # POST /libcheck_data_files
  # POST /libcheck_data_files.json
  def create
    @libcheck_data_file = LibcheckDataFile.new
    @libcheck_data_file.library_check_id = params[:libcheck_data_file][:library_check_id]
    @libcheck_data_file.uploaded_at = Time.now
    respond_to do |format|
      if @libcheck_data_file.update_attributes(params[:libcheck_data_file])
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.libcheck_data_file'))
        format.html { redirect_to(@libcheck_data_file)}
        format.json { render :json => @libcheck_data_file, :status => :created, :location => @libcheck_data_file }
      else
        format.html { render :action => "new", :library_check_id => params[:libcheck_data_file][:library_check_id]}
        format.json { render :json => @libcheck_data_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @libcheck_data_file = LibcheckDataFile.find(params[:id])
  end  

  # DELETE /libcheck_data_files/1
  # DELETE /libcheck_data_files/1.json
  def destroy
    @libcheck_data_file = LibcheckDataFile.find(params[:id])
    @library_check_id = @libcheck_data_file.library_check_id
#    @library_cehck_data_upload.destroy
    @libcheck_data_file.destroy
    respond_to do |format|
      format.html { redirect_to :action => 'index', :library_check_id => @library_check_id}
      format.json { head :no_content }
    end
  end

end
