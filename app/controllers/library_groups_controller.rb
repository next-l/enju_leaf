# -*- encoding: utf-8 -*-
class LibraryGroupsController < ApplicationController
  load_and_authorize_resource
  cache_sweeper :library_group_sweeper, :only => [:update]

  # GET /library_groups
  # GET /library_groups.json
  def index
    @library_groups = LibraryGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @library_groups }
    end
  end

  # GET /library_groups/1
  # GET /library_groups/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @library_group }
    end
  end

  # GET /library_groups/1/edit
  def edit
    @countries = Country.all
  end

  # PUT /library_groups/1
  # PUT /library_groups/1.json
  def update
    @library_group = LibraryGroup.find(params[:id])
    respond_to do |format|
      if @library_group.update_attributes(params[:library_group])
        expire_page '/page/opensearch'
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.library_group'))
        format.html { redirect_to library_group_url(@library_group) }
        format.json { head :no_content }
      else
        @countries = Country.all
        format.html { render :action => "edit" }
        format.json { render :json => @library_group.errors, :status => :unprocessable_entity }
      end
    end
  end
end
