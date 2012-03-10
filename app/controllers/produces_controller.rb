class ProducesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_manifestation
  before_filter :prepare_options, :only => [:new, :edit]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /produces
  # GET /produces.json
  def index
    case
    when @patron
      @produces = @patron.produces.order('produces.position').page(params[:page])
    when @manifestation
      @produces = @manifestation.produces.order('produces.position').page(params[:page])
    else
      @produces = Produce.page(params[:page])
    end

    respond_to do |format|
      format.html # index.rhtml
      format.json { render :json => @produces }
    end
  #rescue
  #  respond_to do |format|
  #    format.html { render :action => "new" }
  #    format.json { render :json => @produce.errors, :status => :unprocessable_entity }
  #  end
  end

  # GET /produces/1
  # GET /produces/1.json
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.json { render :json => @produce }
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
      @produce = Produce.new(:manifestation => @manifestation, :patron => @patron)
    end
  end

  # GET /produces/1;edit
  def edit
  end

  # POST /produces
  # POST /produces.json
  def create
    @produce = Produce.new(params[:produce])

    respond_to do |format|
      if @produce.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.produce'))
        format.html { redirect_to(@produce) }
        format.json { render :json => @produce, :status => :created, :location => @produce }
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @produce.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /produces/1
  # PUT /produces/1.json
  def update
    if @manifestation and params[:move]
      if ['higher', 'lower'].include?(params[:move])
        @produce.send("move_#{params[:move]}")
        redirect_to manifestation_produces_url(@manifestation)
        return
      end
    end

    respond_to do |format|
      if @produce.update_attributes(params[:produce])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.produce'))
        format.html { redirect_to produce_url(@produce) }
        format.json { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @produce.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /produces/1
  # DELETE /produces/1.json
  def destroy
    @produce.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.produce'))
      case
      when @patron
        format.html { redirect_to patron_manifestations_url(@patron) }
        format.json { head :no_content }
      when @manifestation
        format.html { redirect_to manifestation_patrons_url(@manifestation) }
        format.json { head :no_content }
      else
        format.html { redirect_to produces_url }
        format.json { head :no_content }
      end
    end
  end

  private
  def prepare_options
    @produce_types = ProduceType.all
  end
end
