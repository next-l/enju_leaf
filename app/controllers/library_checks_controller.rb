class LibraryChecksController < ApplicationController
  load_and_authorize_resource

  # GET /library_checks
  # GET /library_checks.xml
  def index
    @library_checks = LibraryCheck.find(:all, :conditions => ["deleted_at IS NULL"])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @library_checks }
    end
  end

  def show
    #start 2011.05.19
    @library_check = LibraryCheck.find(params[:id])
    msg = nil
    if params[:mode] == "exec"
      begin
        if @library_check.preprocess?
          msg = I18n.t('activerecord.errors.messages.library_check.start_process')
        else
          msg = I18n.t('activerecord.errors.messages.library_check.start_process_failed')
        end
      rescue => exc
        Rails.logger.error exc.to_s
        msg = I18n.t('activerecord.errors.messages.library_check.start_process_failed')
        @library_check.error_msg = msg + exc.to_s
        @library_check.save!
      end

      flash[:notice] = msg unless msg.nil?
    end
    #end check execute mode: 2011.05.19

    respond_to do |format|
      format.html # show.html.erb
      format.download { redirect_to :action => 'download_file', :id => @library_check, :file => params[:file], :status => 301}
    end
 end

  # POST /library_checks
  # POST /library_checks.xml
  def create
    @library_check = LibraryCheck.new
    @library_check.opeym = params[:library_check][:opeym]

    respond_to do |format|
      if @library_check.save
        format.html { redirect_to(@library_check) }
        format.xml  { render :xml => @library_check, :status => :created, :location => @library_check }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @library_check.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /library_checks/1/edit
  def edit
    @library_check = LibraryCheck.find(params[:id])
  end

  # PUT /library_checks/1
  # PUT /library_checks/1.xml
  def update
    @library_check = LibraryCheck.find(params[:id])
    if params[:library_check].blank?
       @library_check.file_update_flg = true
    else
       @library_check.file_update_flg = false
    end
  
    respond_to do |format|
      if @library_check.update_attributes(params[:library_check])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.library_check'))
        @library_check.send_later(:delayed_import, @library_check.shelf_upload.path)
        format.html { redirect_to(@library_check) }
        format.xml  { head :ok }
      else
        if @library_check.file_update_flg
           format.html { render :template => "library_check_shelves/index"}
           format.xml  { render :xml => @library_check, :status => :unprocessable_entity }
        else
           format.html { render :action => "edit" }
           format.xml  { render :xml => @library_check.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /library_checks/1
  # DELETE /library_checks/1.xml
  def destroy
    @library_check = LibraryCheck.find(params[:id])
    @library_check.deleted_at = Time.now
    @library_check.save

    respond_to do |format|
      format.html { redirect_to(library_checks_url) }
      format.xml  { head :ok }
    end
  end

  def download_file
    file = params[:file]
    id = params[:id]
    if file == "pdf"
       filename  = @library_check.shelf_def_file.gsub(/\..+?$/,'.pdf')
       path = "#{RAILS_ROOT}/private/system/shelf_uploads/#{id}/original/#{filename}"
    elsif file == "resource_list"
       path = "#{RAILS_ROOT}/private/system/library_check/#{id}/resource_list.csv"
    elsif file == "notfound_list"
       path = "#{RAILS_ROOT}/private/system/library_check/#{id}/notfound_list.csv"
    end
    if File.exist?(path)
      send_file path #, :type => "application/pdf"
    else
      redirect_to :back
    end
  end

end
