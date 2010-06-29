class ProducesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_manifestation
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /produces
  # GET /produces.xml
  def index
    case
    when @patron
      @produces = @patron.produces.paginate(:page => params[:page], :order => ['position'])
    when @manifestation
      @produces = @manifestation.produces.paginate(:page => params[:page], :order => ['position'])
    else
      @produces = Produce.paginate(:all, :page => params[:page], :order => ['position'])
    end
      
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @produces }
    end
  #rescue
  #  respond_to do |format|
  #    format.html { render :action => "new" }
  #    format.xml  { render :xml => @produce.errors.to_xml }
  #  end
  end

  # GET /produces/1
  # GET /produces/1.xml
  def show
    @produce = Produce.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @produce }
    end
  end

  # GET /produces/new
  def new
    if @patron and @manifestation.blank?
      redirect_to patron_manifestations_url(@patron)
      return
    elsif @manifestation and @patron.blank?
      redirect_to manifestation_patrons_url(@manifestation)
      return
    else
      @produce = Produce.new
      @produce.patron = @patron
      @produce.manifestation = @manifestation
    end
  end

  # GET /produces/1;edit
  def edit
    @produce = Produce.find(params[:id])
  end

  # POST /produces
  # POST /produces.xml
  def create
    @produce = Produce.new(params[:produce])

    respond_to do |format|
      if @produce.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.produce'))
        format.html { redirect_to(@produce) }
        format.xml  { render :xml => @produce, :status => :created, :location => @produce }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @produce.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /produces/1
  # PUT /produces/1.xml
  def update
    @produce = Produce.find(params[:id])

    if @manifestation and params[:position]
      @produce.insert_at(params[:position])
      redirect_to manifestation_patrons_url(@manifestation)
      return
    end

    respond_to do |format|
      if @produce.update_attributes(params[:produce])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.produce'))
        if @patron
          format.html { redirect_to patron_manifestations_url(@patron) }
          format.xml  { head :ok }
        elsif @manifestation
          format.html { redirect_to manifestation_patrons_url(@manifestation) }
          format.xml  { head :ok }
        else
          format.html { redirect_to produce_url(@produce) }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @produce.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /produces/1
  # DELETE /produces/1.xml
  def destroy
    @produce = Produce.find(params[:id])
    @produce.destroy

    respond_to do |format|
      case
      when @patron
        format.html { redirect_to patron_manifestations_url(@patron) }
        format.xml  { head :ok }
      when @manifestation
        format.html { redirect_to manifestation_patrons_url(@manifestation) }
        format.xml  { head :ok }
      else
        format.html { redirect_to produces_url }
        format.xml  { head :ok }
      end
    end
  end
end
