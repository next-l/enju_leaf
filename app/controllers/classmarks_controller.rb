class ClassmarksController < ApplicationController
  load_and_authorize_resource

  def index
    @classmarks = Classmark.page(params[:page])
  end

  def create
    @classmark = Classmark.new(params[:classmark])
      respond_to do |format|
      if @classmark.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.classmark'))
        format.html { redirect_to(@classmark) }
        format.json { render :json => @department, :status => :created, :location => @classmark }
      else
        format.html { render :action => "new" }
        format.json { render :json => @classmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @classmark = Classmark.find(params[:id])
    respond_to do |format|
      if @classmark.update_attributes(params[:classmark])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.classmark'))
        format.html { redirect_to(@classmark) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @classmark.errors, :status => :unprocessable_entity }
      end
    end
  end
end
