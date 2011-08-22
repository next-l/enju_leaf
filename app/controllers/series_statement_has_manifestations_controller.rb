# -*- encoding: utf-8 -*-
class SeriesStatementHasManifestationsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_manifestation, :only => [:index, :new, :edit]
  before_filter :get_series_statement, :only => [:index, :new, :edit]

  # GET /series_statement_has_manifestations
  # GET /series_statement_has_manifestations.xml
  def index
    @series_statement_has_manifestations = SeriesStatementHasManifestation.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @series_statement_has_manifestations }
    end
  end

  # GET /series_statement_has_manifestations/1
  # GET /series_statement_has_manifestations/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @series_statement_has_manifestation }
      format.js
    end
  end

  # GET /series_statement_has_manifestations/new
  # GET /series_statement_has_manifestations/new.xml
  def new
    @series_statement_has_manifestation = SeriesStatementHasManifestation.new(:series_statement => @series_statement, :manifestation => @manifestation)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @series_statement_has_manifestation }
    end
  end

  # GET /series_statement_has_manifestations/1/edit
  def edit
  end

  # POST /series_statement_has_manifestations
  # POST /series_statement_has_manifestations.xml
  def create
    respond_to do |format|
      if @series_statement_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.series_statement_has_manifestation'))
        format.html { redirect_to(@series_statement_has_manifestation) }
        format.xml  { render :xml => @series_statement_has_manifestation, :status => :created, :location => @series_statement_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @series_statement_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series_statement_has_manifestations/1
  # PUT /series_statement_has_manifestations/1.xml
  def update
    respond_to do |format|
      if @series_statement_has_manifestation.update_attributes(params[:series_statement_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.series_statement_has_manifestation'))
        format.html { redirect_to(@series_statement_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @series_statement_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statement_has_manifestations/1
  # DELETE /series_statement_has_manifestations/1.xml
  def destroy
    @series_statement_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(series_statement_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end
