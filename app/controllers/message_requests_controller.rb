class MessageRequestsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /message_requests
  # GET /message_requests.xml
  def index
    case params[:mode]
    when 'sent'
      @message_requests = MessageRequest.sent.order('created_at DESC').page(params[:page])
    when 'all'
      @message_requests = MessageRequest.order('created_at DESC').page(params[:page])
    else
      @message_requests = MessageRequest.not_sent.order('created_at DESC').page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @message_requests }
    end
  end

  # GET /message_requests/1
  # GET /message_requests/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message_request }
    end
  end

  # GET /message_requests/1/edit
  def edit
    @message_templates = MessageTemplate.all
  end

  # PUT /message_requests/1
  # PUT /message_requests/1.xml
  def update
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
    @message_request.destroy

    respond_to do |format|
      format.html { redirect_to(message_requests_url) }
      format.xml  { head :ok }
    end
  end
end
