class ExemplifiesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_manifestation, :get_item
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /exemplifies
  # GET /exemplifies.xml
  def index
    @exemplifies = Exemplify.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exemplifies }
    end
  end

  # GET /exemplifies/1
  # GET /exemplifies/1.xml
  def show
    @exemplify = Exemplify.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exemplify }
    end
  end

  # GET /exemplifies/new
  # GET /exemplifies/new.xml
  def new
    @exemplify = Exemplify.new
    @exemplify.manifestation = @manifestation
    @exemplify.item = @item

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exemplify }
    end
  end

  # GET /exemplifies/1/edit
  def edit
    @exemplify = Exemplify.find(params[:id])
  end

  # POST /exemplifies
  # POST /exemplifies.xml
  def create
    @exemplify = Exemplify.new(params[:exemplify])

    respond_to do |format|
      if @exemplify.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.exemplify'))
        format.html { redirect_to(@exemplify) }
        format.xml  { render :xml => @exemplify, :status => :created, :location => @exemplify }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exemplify.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exemplifies/1
  # PUT /exemplifies/1.xml
  def update
    @exemplify = Exemplify.find(params[:id])

    respond_to do |format|
      if @exemplify.update_attributes(params[:exemplify])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.exemplify'))
        case when @manifestation
          format.html { redirect_to manifestation_items_path(@exemplify.manifestation) }
          format.xml  { head :ok }
        when @item
          format.html { redirect_to @exemplify.item }
          format.xml  { head :ok }
        else
          format.html { redirect_to(@exemplify) }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exemplify.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exemplifies/1
  # DELETE /exemplifies/1.xml
  def destroy
    @exemplify = Exemplify.find(params[:id])
    @exemplify.destroy

    respond_to do |format|
      case when @manifestation
        format.html { redirect_to manifestation_items_path(@exemplify.manifestation) }
        format.xml  { head :ok }
      when @item
        format.html { redirect_to @exemplify.item }
        format.xml  { head :ok }
      else
        format.html { redirect_to exemplifies_url }
        format.xml  { head :ok }
      end
    end
  end
end
