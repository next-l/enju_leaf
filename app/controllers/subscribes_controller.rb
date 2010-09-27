class SubscribesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_subscription, :get_work

  # GET /subscribes
  # GET /subscribes.xml
  def index
    @subscribes = Subscribe.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subscribes }
    end
  end

  # GET /subscribes/1
  # GET /subscribes/1.xml
  def show
    @subscribe = Subscribe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subscribe }
    end
  end

  # GET /subscribes/new
  # GET /subscribes/new.xml
  def new
    @subscribe = Subscribe.new
    @subscribe.subscription = @subscription if @subscription
    @subscribe.work = @work if @work

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subscribe }
    end
  end

  # GET /subscribes/1/edit
  def edit
    @subscribe = Subscribe.find(params[:id])
  end

  # POST /subscribes
  # POST /subscribes.xml
  def create
    @subscribe = Subscribe.new(params[:subscribe])

    respond_to do |format|
      if @subscribe.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.subscribe'))
        format.html { redirect_to(@subscribe) }
        format.xml  { render :xml => @subscribe, :status => :created, :location => @subscribe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subscribe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subscribes/1
  # PUT /subscribes/1.xml
  def update
    @subscribe = Subscribe.find(params[:id])

    respond_to do |format|
      if @subscribe.update_attributes(params[:subscribe])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.subscribe'))
        format.html { redirect_to(@subscribe) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subscribe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subscribes/1
  # DELETE /subscribes/1.xml
  def destroy
    @subscribe = Subscribe.find(params[:id])
    @subscribe.destroy

    respond_to do |format|
      format.html { redirect_to(subscribes_url) }
      format.xml  { head :ok }
    end
  end
end
