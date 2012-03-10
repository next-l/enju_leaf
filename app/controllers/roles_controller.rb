class RolesController < ApplicationController
  load_and_authorize_resource

  # GET /roles
  # GET /roles.json
  def index
    respond_to do |format|
      format.html # index.rhtml
      format.json { render :json => @roles.to_json }
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.json { render :json => @role.to_json }
    end
  end

  # GET /roles/1;edit
  def edit
  end

  # PUT /roles/1
  # PUT /roles/1.json
  def update
    if params[:move]
      move_position(@role, params[:move])
      return
    end

    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.role'))
        format.html { redirect_to role_url(@role) }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
end
