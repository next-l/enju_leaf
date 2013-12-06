class ImportRequestsController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.import_request'))", 'import_requests_path', :only => [:index]
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.import_request'))", 'import_request_path(params[:id])', :only => [:show]
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.import_request'))", 'new_import_request_path', :only => [:new, :create]
  load_and_authorize_resource

  # GET /import_requests
  # GET /import_requests.json
  def index
    @import_requests = ImportRequest.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @import_requests }
    end
  end

  # GET /import_requests/1
  # GET /import_requests/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @import_request }
    end
  end

  # GET /import_requests/new
  # GET /import_requests/new.json
  def new
    @import_request = ImportRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @import_request }
    end
  end

  # GET /import_requests/1/edit
  def edit
  end

  # POST /import_requests
  # POST /import_requests.json
  def create
    @import_request = ImportRequest.new(params[:import_request])
    @import_request.user = current_user
    
    respond_to do |format|
      if @import_request.save
        @import_request.import!
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.import_request'))
        format.html { redirect_to new_import_request_path }
        format.json { render :json => @import_request, :status => :created, :location => @import_request }
      else
        format.html { render :action => "new" }
        format.json { render :json => @import_request.errors, :status => :unprocessable_entity }
      end
    end
  rescue Timeout::Error
    @import_request.sm_fail!
    flash[:notice] = t('page.timed_out')
    redirect_to new_import_request_url
  end

  # PUT /import_requests/1
  # PUT /import_requests/1.json
  def update
    respond_to do |format|
      if @import_request.update_attributes(params[:import_request])
        @import_request.import!
        format.html { redirect_to @import_request, :notice => t('controller.successfully_updated', :model => t('activerecord.models.import_request')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @import_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /import_requests/1
  # DELETE /import_requests/1.json
  def destroy
    @import_request.destroy

    respond_to do |format|
      format.html { redirect_to import_requests_url }
      format.json { head :no_content }
    end
  end
end
