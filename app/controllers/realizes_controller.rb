class RealizesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_expression
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /realizes
  # GET /realizes.json
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
      format.html # index.html.erb
      format.json { render :json => @realizes }
    end
  end

  # GET /realizes/1
  # GET /realizes/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @realize }
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

  # GET /realizes/1/edit
  def edit
  end

  # POST /realizes
  # POST /realizes.json
  def create
    @realize = Realize.new(params[:realize])

    respond_to do |format|
      if @realize.save
        format.html { redirect_to @realize, :notice => t('controller.successfully_created', :model => t('activerecord.models.realize')) }
        format.json { render :json => @realize, :status => :created, :location => @realize }
      else
        format.html { render :action => "new" }
        format.json { render :json => @realize.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /realizes/1
  # PUT /realizes/1.json
  def update
    # 並べ替え
    if @expression and params[:position]
      @realize.insert_at(params[:position])
      redirect_to expression_realizes_url(@expression)
      return
    end

    respond_to do |format|
      if @realize.update_attributes(params[:realize])
        format.html { redirect_to @realize, :notice => t('controller.successfully_updated', :model => t('activerecord.models.realize')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @realize.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /realizes/1
  # DELETE /realizes/1.json
  def destroy
    @realize.destroy

    respond_to do |format|
      case
      when @expression
        format.html { redirect_to expression_patrons_url(@expression) }
        format.json { head :no_content }
      when @patron
        format.html { redirect_to patron_expressions_url(@patron) }
        format.json { head :no_content }
      else
        format.html { redirect_to realizes_url }
        format.json { head :no_content }
      end
    end
  end
end
