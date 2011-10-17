class RealizesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_expression
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /realizes
  # GET /realizes.xml
  def index
    case
    when @patron
      @realizes = @patron.realizes.order('realizes.position').page(params[:page])
    when @expression
      @realizes = @expression.realizes.order('realizes.position').page(params[:page])
    else
      @realizes = Realize.page(params[:page])
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @realizes }
    end
  end

  # GET /realizes/1
  # GET /realizes/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @realize }
    end
  end

  # GET /realizes/new
  def new
    if @expression and @patron.blank?
      redirect_to expression_patrons_url(@expression)
      return
    elsif @patron and @expression.blank?
      redirect_to patron_expressions_url(@patron)
      return
    else
      @realize = Realize.new(:expression => @expression, :patron => @patron)
    end
  end

  # GET /realizes/1;edit
  def edit
  end

  # POST /realizes
  # POST /realizes.xml
  def create
    @realize = Realize.new(params[:realize])

    respond_to do |format|
      if @realize.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.realize'))
        format.html { redirect_to(@realize) }
        format.xml  { render :xml => @realize, :status => :created, :location => @realize }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @realize.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /realizes/1
  # PUT /realizes/1.xml
  def update
    # 並べ替え
    if @expression and params[:position]
      @realize.insert_at(params[:position])
      redirect_to expression_realizes_url(@expression)
      return
    end

    respond_to do |format|
      if @realize.update_attributes(params[:realize])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.realize'))
        format.html { redirect_to realize_url(@realize) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @realize.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /realizes/1
  # DELETE /realizes/1.xml
  def destroy
    @realize.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.realize'))
      case
      when @expression
        format.html { redirect_to expression_patrons_url(@expression) }
        format.xml  { head :ok }
      when @patron
        format.html { redirect_to patron_expressions_url(@patron) }
        format.xml  { head :ok }
      else
        format.html { redirect_to realizes_url }
        format.xml  { head :ok }
      end
    end
  end
end
