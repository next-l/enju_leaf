class CreatesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_work
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /creates
  # GET /creates.json
  def index
    case
    when @patron
      @creates = @patron.creates.order('creates.position').page(params[:page])
    when @work
      @creates = @work.creates.order('creates.position').page(params[:page])
    else
      @creates = Create.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @creates }
    end
  end

  # GET /creates/1
  # GET /creates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @create }
    end
  end

  # GET /creates/new
  def new
    if @patron and @work.blank?
      redirect_to patron_works_url(@patorn)
      return
    elsif @work and @patron.blank?
      redirect_to work_patrons_url(@work)
      return
    else
      @create = Create.new(:work => @work, :patron => @patron)
    end
  end

  # GET /creates/1/edit
  def edit
  end

  # POST /creates
  # POST /creates.json
  def create
    @create = Create.new(params[:create])

    respond_to do |format|
      if @create.save
        format.html { redirect_to @create, :notice => t('controller.successfully_created', :model => t('activerecord.models.create')) }
        format.json { render :json => @create, :status => :created, :location => @create }
      else
        format.html { render :action => "new" }
        format.json { render :json => @create.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /creates/1
  # PUT /creates/1.json
  def update
    # 並べ替え
    if @work and params[:position]
      @create.insert_at(params[:position])
      redirect_to work_creates_url(@work)
      return
    end

    respond_to do |format|
      if @create.update_attributes(params[:create])
        format.html { redirect_to @create, :notice => t('controller.successfully_updated', :model => t('activerecord.models.create')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @create.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /creates/1
  # DELETE /creates/1.json
  def destroy
    @create.destroy

    respond_to do |format|
      case
      when @patron
        format.html { redirect_to patron_works_url(@patron) }
        format.json { head :no_content }
      when @work
        format.html { redirect_to work_patrons_url(@work) }
        format.json { head :no_content }
      else
        format.html { redirect_to creates_url }
        format.json { head :no_content }
      end
    end
  end
end
