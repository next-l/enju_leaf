# -*- encoding: utf-8 -*-
class LibraryGroupsController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.library_group'))", 'library_groups_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.library_group'))", 'new_library_group_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.library_group'))", 'edit_library_group_path(params[:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.library_group')", 'library_group_path(params[:id])', :only => [:show]
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
    respond_to do |format|
      if @library_group.update_attributes(params[:library_group])
        expire_page '/page/opensearch'
        format.html { redirect_to @library_group, :notice => t('controller.successfully_updated', :model => t('activerecord.models.library_group')) }
        format.json { head :no_content }
      else
        @countries = Country.all
        format.html { render :action => "edit" }
        format.json { render :json => @library_group.errors, :status => :unprocessable_entity }
      end
    end
  end
end
