class DonatesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /donates
  # GET /donates.xml
  def index
    @donates = Donate.paginate(:all, :order => ['id DESC'], :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @donates }
    end
  end

  # GET /donates/1
  # GET /donates/1.xml
  def show
    @donate = Donate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @donate }
    end
  end

  # GET /donates/new
  # GET /donates/new.xml
  def new
    @donate = Donate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @donate }
    end
  end

  # GET /donates/1/edit
  def edit
    @donate = Donate.find(params[:id])
  end

  # POST /donates
  # POST /donates.xml
  def create
    @donate = Donate.new(params[:donate])

    respond_to do |format|
      if @donate.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.donate'))
        format.html { redirect_to(@donate) }
        format.xml  { render :xml => @donate, :status => :created, :location => @donate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @donate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /donates/1
  # PUT /donates/1.xml
  def update
    @donate = Donate.find(params[:id])

    respond_to do |format|
      if @donate.update_attributes(params[:donate])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.donate'))
        format.html { redirect_to(@donate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @donate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /donates/1
  # DELETE /donates/1.xml
  def destroy
    @donate = Donate.find(params[:id])
    @donate.destroy

    respond_to do |format|
      format.html { redirect_to(donates_url) }
      format.xml  { head :ok }
    end
  end
end
