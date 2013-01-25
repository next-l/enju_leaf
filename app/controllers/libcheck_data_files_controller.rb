class LibcheckDataFilesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.libcheck_data_file'))", 'library_check_libcheck_data_files_path(params[:library_check_id])', :except => [:show, :create]
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.libcheck_data_file'))", 'new_library_check_libcheck_data_file_path', :only => [:new]
  add_breadcrumb "I18n.t('activerecord.models.libcheck_data_file')", 'libcheck_data_file_path(params[:id])', :only => [:show]
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
