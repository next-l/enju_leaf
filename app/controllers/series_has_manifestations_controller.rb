# -*- encoding: utf-8 -*-
class SeriesHasManifestationsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_manifestation#, :only => [:index, :new, :edit, :create, :destroy]
  before_filter :get_series_statement, :only => [:index, :new, :create, :edit, :update]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /series_has_manifestations
  # GET /series_has_manifestations.json
  def index
    @series_has_manifestations = SeriesHasManifestation.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @series_has_manifestations }
    end
  end

  # GET /series_has_manifestations/1
  # GET /series_has_manifestations/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @series_has_manifestation }
      format.js
    end
  end

  # GET /series_has_manifestations/new
  # GET /series_has_manifestations/new.json
  def new
    @series_has_manifestation = SeriesHasManifestation.new(:series_statement => @series_statement, :manifestation => @manifestation)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @series_has_manifestation }
    end
  end

  # GET /series_has_manifestations/1/edit
  def edit
    @series_has_manifestation.series_statement = @series_statement if @series_statement
    @series_has_manifestation.manifestation = @manifestation if @manifestation
  end

  # POST /series_has_manifestations
  # POST /series_has_manifestations.json
  def create
    respond_to do |format|
      if @series_has_manifestation.save
        if params[:mode] == 'edit_manifestation'
          format.html { redirect_to edit_manifestation_path(@series_has_manifestation.manifestation) }
        else
          format.html { redirect_to @series_has_manifestation, :notice => t('controller.successfully_created', :model => t('activerecord.models.series_has_manifestation')) }
          format.json { render :json => @series_has_manifestation, :status => :created, :location => @series_has_manifestation }
        end
      else
        format.html { render :action => "new" }
        format.json { render :json => @series_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series_has_manifestations/1
  # PUT /series_has_manifestations/1.json
  def update
    respond_to do |format|
      old_series_statement = @series_has_manifestation.series_statement
      if @series_has_manifestation.update_attributes(params[:series_has_manifestation])
        old_series_statement.index
        if params[:mode] == 'edit_manifestation'
          format.html { redirect_to edit_manifestation_path(@series_has_manifestation.manifestation) }
        else
          format.html { redirect_to @series_has_manifestation, :notice => t('controller.successfully_updated', :model => t('activerecord.models.series_has_manifestation')) }
          format.json { head :no_content }
        end
      else
        format.html { render :action => "edit" }
        format.json { render :json => @series_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series_has_manifestations/1
  # DELETE /series_has_manifestations/1.json
  def destroy
    @series_has_manifestation.destroy

    respond_to do |format|
      format.html {
        if params[:mode] == 'edit_manifestation'
          redirect_to edit_manifestation_path(@series_has_manifestation.manifestation)
        else
          if @manifestation
            redirect_to(manifestation_series_statements_url(@manifestation))
          else
            redirect_to(series_has_manifestations_url)
          end
        end
      }
      format.json { head :no_content }
    end
  end
end
