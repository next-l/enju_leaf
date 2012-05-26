class ExemplifiesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_manifestation, :get_item
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /exemplifies
  # GET /exemplifies.json
  def index
    @exemplifies = Exemplify.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @exemplifies }
    end
  end

  # GET /exemplifies/1
  # GET /exemplifies/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @exemplify }
    end
  end

  # GET /exemplifies/new
  # GET /exemplifies/new.json
  def new
    if @manifestation and @item.blank?
      redirect_to manifestation_items_url(@manifestation)
      return
    elsif @item and @manifestation.blank?
      redirect_to manifestations_url
      return
    else
      @exemplify = Exemplify.new
      @exemplify.manifestation = @manifestation
      @exemplify.item = @item
    end
  end

  # GET /exemplifies/1/edit
  def edit
    @exemplify.manifestation = @manifestation if @manifestation
  end

  # POST /exemplifies
  # POST /exemplifies.json
  def create
    @exemplify = Exemplify.new(params[:exemplify])

    respond_to do |format|
      if @exemplify.save
        format.html { redirect_to @exemplify, :notice => t('controller.successfully_created', :model => t('activerecord.models.exemplify')) }
        format.json { render :json => @exemplify, :status => :created, :location => @exemplify }
      else
        format.html { render :action => "new" }
        format.json { render :json => @exemplify.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exemplifies/1
  # PUT /exemplifies/1.json
  def update
    if @manifestation and params[:move]
      move_position(@exemplify, params[:move], false)
      redirect_to manifestation_exemplifies_url(@manifestation)
      return
    end

    respond_to do |format|
      if @exemplify.update_attributes(params[:exemplify])
        format.html { redirect_to @exemplify, :notice => t('controller.successfully_updated', :model => t('activerecord.models.exemplify')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @exemplify.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exemplifies/1
  # DELETE /exemplifies/1.json
  def destroy
    @exemplify.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.exemplify'))
        case when @manifestation
          redirect_to @exemplify.manifestation
        when @item
          redirect_to @exemplify.item
        else
          redirect_to exemplifies_url
        end
      }
      format.json { head :no_content }
    end
  end
end
