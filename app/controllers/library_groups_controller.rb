# -*- encoding: utf-8 -*-
class LibraryGroupsController < ApplicationController
  load_and_authorize_resource
  cache_sweeper :library_group_sweeper, :only => [:create, :update, :destroy]

  # GET /library_groups
  # GET /library_groups.xml
  def index
    @library_groups = LibraryGroup.all

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @library_groups.to_xml }
    end
  end

  # GET /library_groups/1
  # GET /library_groups/1.xml
  def show
    @library_group = LibraryGroup.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @library_group.to_xml }
    end
  end

  # GET /library_groups/new
  #def new
  #  @library_group = LibraryGroup.new
  #end

  # GET /library_groups/1;edit
  def edit
    @library_group = LibraryGroup.find(params[:id])
    @countries = Country.all
  end

  # POST /library_groups
  # POST /library_groups.xml
  def create
    access_denied
  #  @library_group = LibraryGroup.new(params[:library_group])
  #
  #  respond_to do |format|
  #    if @library_group.save
  #      flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.library_group'))
  #      format.html { redirect_to library_group_url(@library_group) }
  #      format.xml  { head :created, :location => library_group_url(@library_group) }
  #    else
  #      format.html { render :action => "new" }
  #      format.xml  { render :xml => @library_group.errors.to_xml }
  #    end
  #  end
  end

  # PUT /library_groups/1
  # PUT /library_groups/1.xml
  def update
    @library_group = LibraryGroup.find(params[:id])

    respond_to do |format|
      if @library_group.update_attributes(params[:library_group])
        expire_page '/page/opensearch'
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.library_group'))
        format.html { redirect_to library_group_url(@library_group) }
        format.xml  { head :ok }
      else
        @countries = Country.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @library_group.errors.to_xml }
      end
    end
  end

  # DELETE /library_groups/1
  # DELETE /library_groups/1.xml
  def destroy
    access_denied
  #  @library_group = LibraryGroup.find(params[:id])
  #  @library_group.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to library_groups_url }
  #    format.xml  { head :ok }
  #  end
  end
end
