class ImportRequestsController < ApplicationController
  load_and_authorize_resource

  # GET /import_requests
  # GET /import_requests.xml
  def index
    @import_requests = ImportRequest.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @import_requests }
    end
  end

  # GET /import_requests/1
  # GET /import_requests/1.xml
  def show
    @import_request = ImportRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @import_request }
    end
  end

  # GET /import_requests/new
  # GET /import_requests/new.xml
  def new
    @import_request = ImportRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @import_request }
    end
  end

  # GET /import_requests/1/edit
  def edit
    @import_request = ImportRequest.find(params[:id])
  end

  # POST /import_requests
  # POST /import_requests.xml
  def create
    @import_request = ImportRequest.new(params[:import_request])
    @import_request.user = current_user

    respond_to do |format|
      if @import_request.save
        @import_request.import!
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.import_request'))
        format.html { redirect_to new_import_request_path }
        format.xml  { render :xml => @import_request, :status => :created, :location => @import_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @import_request.errors, :status => :unprocessable_entity }
      end
    end
  rescue EnjuNdl::RecordNotFound
    flash[:notice] = t('import_request.record_not_found')
    redirect_to new_import_request_url
  #rescue EnjuNdl::InvalidIsbn
  #  flash[:errors] = t('import_request.invalid_isbn')
  #  redirect_to new_import_request_url
  end

  # PUT /import_requests/1
  # PUT /import_requests/1.xml
  def update
    @import_request = ImportRequest.find(params[:id])

    respond_to do |format|
      if @import_request.update_attributes(params[:import_request])
        @import_request.import!
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.import_request'))
        format.html { redirect_to(@import_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @import_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /import_requests/1
  # DELETE /import_requests/1.xml
  def destroy
    @import_request = ImportRequest.find(params[:id])
    @import_request.destroy

    respond_to do |format|
      format.html { redirect_to(import_requests_url) }
      format.xml  { head :ok }
    end
  end
end
