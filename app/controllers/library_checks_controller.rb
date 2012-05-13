class LibraryChecksController < ApplicationController
  load_and_authorize_resource

  # GET /library_checks
  # GET /library_checks.json
  def index
    @library_checks = LibraryCheck.find(:all, :conditions => ["deleted_at IS NULL"], :order => "id DESC")	

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @library_checks }
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
    # exist libcheck files
    dir = "#{Rails.root}/private/system/library_check/#{@library_check.id}/"
    files = ["resource_list","error_list","item_register","notfound_list","detection_list","removing_list"]
    @resource_list_pdf, @resource_list_tsv = false, false 
    @resource_list_pdf = true if File.exist?("#{dir}/resource_list.pdf")
    @resource_list_tsv = true if File.exist?("#{dir}/resource_list.tsv")
    @error_list_pdf, @error_list_tsv = false, false
    @error_list_pdf = true if File.exist?("#{dir}/error_list.pdf")
    @error_list_tsv = true if File.exist?("#{dir}/error_list.tsv")
    @item_register_pdf, @item_register_tsv = false, false
    @item_register_pdf = true if File.exist?("#{dir}/item_register.pdf")
    @item_register_tsv = true if File.exist?("#{dir}/item_register.tsv")
    @notfound_list_pdf, @notfound_list_tsv = false, false
    @notfound_list_pdf = true if File.exist?("#{dir}/notfound_list.pdf")
    @notfound_list_tsv = true if File.exist?("#{dir}/notfound_list.tsv")
    @detection_list_pdf, @detection_list_tsv = false, false
    @detection_list_pdf = true if File.exist?("#{dir}/detection_list.pdf")
    @detection_list_tsv = true if File.exist?("#{dir}/detection_list.tsv")
    @removing_list_pdf, @removing_list_tsv = false, false
    @removing_list_pdf = true if File.exist?("#{dir}/removing_list.pdf")
    @removing_list_tsv = true if File.exist?("#{dir}/removing_list.tsv")

    respond_to do |format|
      format.html # show.html.erb
      format.download { redirect_to :action => 'download_file', :id => @library_check, :file => params[:file], :status => 301}
    end
 end

  # POST /library_checks
  # POST /library_checks.json
  def create
    @library_check = LibraryCheck.new
    @library_check.opeym = params[:library_check][:opeym]

    respond_to do |format|
      if @library_check.save
        format.html { redirect_to(@library_check) }
        format.json { render :json => @library_check, :status => :created, :location => @library_check }
      else
        format.html { render :action => "new" }
        format.json { render :json => @library_check.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /library_checks/1/edit
  def edit
    @library_check = LibraryCheck.find(params[:id])
  end

  # PUT /library_checks/1
  # PUT /library_checks/1.json
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
        format.json { head :no_content }
      else
        if @library_check.file_update_flg
           format.html { render :template => "library_check_shelves/index"}
           format.json { render :json => @library_check, :status => :unprocessable_entity }
        else
           format.html { render :action => "edit" }
           format.json { render :json => @library_check.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /library_checks/1
  # DELETE /library_checks/1.json
  def destroy
    @library_check = LibraryCheck.find(params[:id])
    @library_check.deleted_at = Time.now
    @library_check.save

    respond_to do |format|
      format.html { redirect_to(library_checks_url) }
      format.json { head :no_content }
    end
  end

  def download_file
    if @library_check.shelf_def_file.blank?
      redirect_to :back; return
    end

    file = params[:file]
    id = params[:id]
   
    ext_name = "tsv"
    if params[:format] == "pdf"
      ext_name = "pdf"
    end

    files = ["resource_list","error_list","item_register","notfound_list","detection_list","removing_list"]

    case file 
    when "pdf"
       filename  = @library_check.shelf_def_file.gsub(/\..+?$/,'.pdf')
       path = "#{Rails.root}/private/system/shelf_uploads/#{id}/original/#{filename}"
    when *files
       path = "#{Rails.root}/private/system/library_check/#{id}/#{file}.#{ext_name}"
    end

    if File.exist?(path)
      send_file path #, :type => "application/pdf"
    else
      logger.warn "not exist file. path:#{path}"
      redirect_to :back
    end
  end

end
