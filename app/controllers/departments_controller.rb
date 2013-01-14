class DepartmentsController < ApplicationController
  load_and_authorize_resource

  def index
    @departments = Department.page(params[:page])
  end

  def create
    @department = Department.new(params[:department])
      respond_to do |format|
      if @department.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.department'))
        format.html { redirect_to(@department) }
        format.json { render :json => @department, :status => :created, :location => @department }
      else
        format.html { render :action => "new" }
        format.json { render :json => @area.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @department = Department.find(params[:id])
=begin
    if params[:move]
      move_position(@department, params[:move])
      return
    end
    update!
=end

    respond_to do |format|
      if @department.update_attributes(params[:department])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.department'))
        format.html { redirect_to(@department) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @department.errors, :status => :unprocessable_entity }
      end
    end
  end

   def destroy
    @department = Department.find(params[:id])
    @department.destroy
    respond_to do |format|
      format.html { redirect_to(departments_url) }
    end
  end 
end
