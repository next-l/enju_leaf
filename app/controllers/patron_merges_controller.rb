class PatronMergesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_patron, :get_patron_merge_list

  # GET /patron_merges
  # GET /patron_merges.xml
  def index
    if @patron
      @patron_merges = @patron.patron_merges.order('patron_merges.id').page(params[:page])
    elsif @patron_merge_list
      @patron_merges = @patron_merge_list.patron_merges.order('patron_merges.id').includes(:patron).page(params[:page])
    else
      @patron_merges = PatronMerge.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patron_merges }
    end
  end

  # GET /patron_merges/1
  # GET /patron_merges/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patron_merge }
    end
  end

  # GET /patron_merges/new
  # GET /patron_merges/new.xml
  def new
    @patron_merge = PatronMerge.new
    @patron_merge.patron = @patron

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patron_merge }
    end
  end

  # GET /patron_merges/1/edit
  def edit
  end

  # POST /patron_merges
  # POST /patron_merges.xml
  def create
    @patron_merge = PatronMerge.new(params[:patron_merge])

    respond_to do |format|
      if @patron_merge.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron_merge'))
        format.html { redirect_to(@patron_merge) }
        format.xml  { render :xml => @patron_merge, :status => :created, :location => @patron_merge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @patron_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_merges/1
  # PUT /patron_merges/1.xml
  def update
    respond_to do |format|
      if @patron_merge.update_attributes(params[:patron_merge])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron_merge'))
        format.html { redirect_to(@patron_merge) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patron_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_merges/1
  # DELETE /patron_merges/1.xml
  def destroy
    @patron_merge.destroy

    respond_to do |format|
      format.html { redirect_to(patron_merges_url) }
      format.xml  { head :ok }
    end
  end
end
