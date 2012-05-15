class RolesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  cache_sweeper :page_sweeper, :only => :update

  # GET /roles
  # GET /roles.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @role }
    end
  end

  # GET /roles/1/edit
  def edit
  end

  # PUT /roles/1
  # PUT /roles/1.json
  def update
    if params[:position]
      @role.insert_at(params[:position])
      redirect_to roles_url
      return
    end

    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.html { redirect_to @role, :notice => t('controller.successfully_updated', :model => t('activerecord.models.role')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
end
