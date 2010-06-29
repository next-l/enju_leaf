class CreatesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_work
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /creates
  # GET /creates.xml
  def index
    case
    when @patron
      @creates = @patron.creates.paginate(:page => params[:page], :order => ['position'])
    when @work
      @creates = @work.creates.paginate(:page => params[:page], :order => ['position'])
    else
      @creates = Create.paginate(:all, :page => params[:page], :order => :id)
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @creates }
    end
  end

  # GET /creates/1
  # GET /creates/1.xml
  def show
    @create = Create.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @create }
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
      @create = Create.new
      @create.patron = @patron
      @create.work = @work
    end
  end

  # GET /creates/1;edit
  def edit
    @create = Create.find(params[:id])
  end

  # POST /creates
  # POST /creates.xml
  def create
    @create = Create.new(params[:create])

    respond_to do |format|
      if @create.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.create'))
        format.html { redirect_to(@create) }
        format.xml  { render :xml => @create, :status => :created, :location => @create }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @create.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /creates/1
  # PUT /creates/1.xml
  def update
    @create = Create.find(params[:id])

    # 並べ替え
    if @work and params[:position]
      @create.insert_at(params[:position])
      redirect_to work_creates_url(@work)
      return
    end

    respond_to do |format|
      if @create.update_attributes(params[:create])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.create'))
        if @patron
          format.html { redirect_to patron_works_url(@patron) }
          format.xml  { head :ok }
        elsif @work
          format.html { redirect_to work_patrons_url(@work) }
          format.xml  { head :ok }
        else
          format.html { redirect_to create_url(@create) }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @create.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /creates/1
  # DELETE /creates/1.xml
  def destroy
    @create = Create.find(params[:id])
    @create.destroy

    respond_to do |format|
      case
      when @patron
        format.html { redirect_to patron_works_url(@patron) }
        format.xml  { head :ok }
      when @work
        format.html { redirect_to work_patrons_url(@work) }
        format.xml  { head :ok }
      else
        format.html { redirect_to creates_url }
        format.xml  { head :ok }
      end
    end
  end
end
