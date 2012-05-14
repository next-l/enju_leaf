class SubscriptionsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_work
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    if @work
      @subscriptions = @work.subscriptions.page(params[:page])
    else
      @subscriptions = Subscription.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @subscriptions }
    end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @subscription }
    end
  end

  # GET /subscriptions/new
  # GET /subscriptions/new.json
  def new
    @subscription = Subscription.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @subscription }
    end
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(params[:subscription])
    @subscription.user = current_user

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to @subscription, :notice => t('controller.successfully_created', :model => t('activerecord.models.subscription')) }
        format.json { render :json => @subscription, :status => :created, :location => @subscription }
      else
        format.html { render :action => "new" }
        format.json { render :json => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subscriptions/1
  # PUT /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        format.html { redirect_to @subscription, :notice => t('controller.successfully_updated', :model => t('activerecord.models.subscription')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to subscriptions_url }
      format.json { head :no_content }
    end
  end
end
