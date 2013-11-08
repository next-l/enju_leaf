class IdentifierTypesController < ApplicationController
  load_and_authorize_resource

  # GET /identifier_types
  # GET /identifier_types.json
  def index
    @identifier_types = IdentifierType.order(:position).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @identifier_types }
    end
  end

  # GET /identifier_types/1
  # GET /identifier_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @identifier_type }
    end
  end

  # GET /identifier_types/new
  # GET /identifier_types/new.json
  def new
    @identifier_type = IdentifierType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @identifier_type }
    end
  end

  # GET /identifier_types/1/edit
  def edit
  end

  # POST /identifier_types
  # POST /identifier_types.json
  def create
    @identifier_type = IdentifierType.new(params[:identifier_type])

    respond_to do |format|
      if @identifier_type.save
        format.html { redirect_to @identifier_type, :notice => t('controller.successfully_created', :model => t('activerecord.models.identifier_type')) }
        format.json { render :json => @identifier_type, :status => :created, :location => @identifier_type }
      else
        format.html { render :action => "new" }
        format.json { render :json => @identifier_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /identifier_types/1
  # PUT /identifier_types/1.json
  def update
    if params[:move]
      move_position(@identifier_type, params[:move])
      return
    end

    respond_to do |format|
      if @identifier_type.update_attributes(params[:identifier_type])
        format.html { redirect_to @identifier_type, :notice => t('controller.successfully_updated', :model => t('activerecord.models.identifier_type')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @identifier_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /identifier_types/1
  # DELETE /identifier_types/1.json
  def destroy
    @identifier_type.destroy

    respond_to do |format|
      format.html { redirect_to identifier_types_url }
      format.json { head :no_content }
    end
  end
end
