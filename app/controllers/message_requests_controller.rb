class MessageRequestsController < ApplicationController
  before_filter :access_denied, :only => [:new, :create]
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /message_requests
  # GET /message_requests.xml
  def index
    case params[:mode]
    when 'sent'
      @message_requests = MessageRequest.sent.paginate(:all, :page => params[:page], :order => 'created_at DESC')
    when 'all'
      @message_requests = MessageRequest.paginate(:all, :page => params[:page], :order => 'created_at DESC')
    else
      @message_requests = MessageRequest.not_sent.paginate(:all, :page => params[:page], :order => 'created_at DESC')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @message_requests }
    end
  end

  # GET /message_requests/1
  # GET /message_requests/1.xml
  def show
    @message_request = MessageRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message_request }
    end
  end

  # GET /message_requests/new
  # GET /message_requests/new.xml
  def new
    @message_request = MessageRequest.new
    @message_templates = MessageTemplate.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message_request }
    end
  end

  # GET /message_requests/1/edit
  def edit
    @message_request = MessageRequest.find(params[:id])
    @message_templates = MessageTemplate.all
  end

  # POST /message_requests
  # POST /message_requests.xml
  def create
    @message_request = MessageRequest.new(params[:message_request])

    respond_to do |format|
      if @message_request.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.message_request'))
        format.html { redirect_to(@message_request) }
        format.xml  { render :xml => @message_request, :status => :created, :location => @message_request }
      else
        @message_templates = MessageTemplate.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @message_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /message_requests/1
  # PUT /message_requests/1.xml
  def update
    @message_request = MessageRequest.find(params[:id])

    respond_to do |format|
      if @message_request.update_attributes(params[:message_request])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.message_request'))
        format.html { redirect_to(@message_request) }
        format.xml  { head :ok }
      else
        @message_templates = MessageTemplate.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /message_requests/1
  # DELETE /message_requests/1.xml
  def destroy
    @message_request = MessageRequest.find(params[:id])
    @message_request.destroy

    respond_to do |format|
      format.html { redirect_to(message_requests_url) }
      format.xml  { head :ok }
    end
  end
end
