class ResourceImportTextfilesController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.resource_import_textfile'))", 'resource_import_textfiles_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.resource_import_textfile'))", 'new_resource_import_textfile_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.resource_import_textfile'))", 'new_resource_import_textfile_path', :only => [:show]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.resource_import_textfile'))", 'edit_resource_import_textfile_path(params[:id])', :only => [:edit, :update]
  before_filter :check_client_ip_address
  load_and_authorize_resource

    
  def index
    @resource_import_textfiles = ResourceImportTextfile.page(params[:page])
  end

  def new
    @resource_import_textfile = ResourceImportTextfile.new
    @adapters = EnjuTrunk::ResourceAdapter::Base.default
  end

  def show
    if @resource_import_textfile.resource_import_text.path
      file = @resource_import_textfile.resource_import_text.path
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @resource_import_textfile }
      format.download {
        send_file file, :filename => @resource_import_textfile.resource_import_text_file_name.encode("cp932"), :type => 'application/octet-stream'
      }
    end
  end

  def create
    @resource_import_textfile = ResourceImportTextfile.new(params[:resource_import_textfile])
    @resource_import_textfile.user = current_user
    extraparams = params[:extraparams]
    sheets = []
    manifestation_types = []
    numberings = []
    auto_numberings = []
    extraparams.each do |e, value|
      if value["sheet"]
        sheets << value["sheet"]
        manifestation_types << value["manifestation_type"]
        numberings << value["numbering"]
        auto_numberings << (value["auto_numbering"] ? true : false)
      end
    end
    params = Hash::new
    params["sheet"] = sheets
    params["manifestation_type"] = manifestation_types
    params["numbering"] = numberings
    params["auto_numbering"] = auto_numberings
    @resource_import_textfile.extraparams = params.to_s

    respond_to do |format|
      if @resource_import_textfile.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_import_textfile'))
        format.html { redirect_to(@resource_import_textfile) }
        format.json { render :json => @resource_import_textfile, :status => :created, :location => @resource_import_textfile }
      else
        @adapters = EnjuTrunk::ResourceAdapter::Base.all
        format.html { render :action => "new" }
        format.json { render :json => @resource_import_textfile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @resource_import_textfile.destroy

    respond_to do |format|
      format.html { redirect_to(resource_import_textfiles_url) }
      format.json { head :no_content }
    end
  end

  def import_request
    begin
      @resource_import_textfile = ResourceImportTextfile.find(params[:id])
      Asynchronized_Service.new.delay.perform(:ResourceImportTextfile_import, @resource_import_textfile.id)
      flash[:message] = t('resource_import_textfile.start_importing')
    rescue Exception => e
      logger.error "Failed to send process to delayed_job: #{e}"
    end
    respond_to do |format|
      format.html {redirect_to(resource_import_textfile_resource_import_textresults_path(@resource_import_textfile))}
    end
  end

  def inherent_view
    a = EnjuTrunk::ResourceAdapter::Base.find_by_classname(params[:name])
    unless a.respond_to?(:template_filename_edit)
      logger.debug "no method template_filename_edit" 
      render :nothing => true, :status => 404 and return
    end
    templatename = a.template_filename_edit
    filename = "lib/enju_trunk/resourceadapter/views/#{templatename}"
    logger.debug "filename=#{filename}"
    render :layout => false, :file => filename
  end

  def upload
    file = params[:resource_import_textfile][:resource_import_text]
    if file.original_filename !~ /.xlsx$/
      render :nothing => true, :status => 404 and return
    end

    filename =  "#{Time.now.instance_eval { '%s%03d' % [strftime('%Y%m%d%H%M%S'), (usec / 1000.0).round] }}.xlsx"
    out_dir = "#{Rails.root}/private/system/resource_import_texts_temp"
    path = "#{out_dir}/#{filename}"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    File.open(path, "wb"){ |f| f.write(file.read) }
    @oo = Excelx.new(path)
    @manifestation_types = ManifestationType.all
    @numberings = Numbering.all
    data = "lib/enju_trunk/resourceadapter/views/excelfile_select.html.erb"
    render :layout => false, :file => data
  end
end
