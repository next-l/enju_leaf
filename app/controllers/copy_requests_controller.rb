class CopyRequestsController < ApplicationController
  load_and_authorize_resource
  before_filter :use_copy_request?

  def index
    if current_user.has_role?('Librarian')
      @copy_requests = CopyRequest.page(params[:page])
    else
      @copy_requests = CopyRequest.where(:user_id => current_user.id).page(params[:page])
    end
  end

  def new
    @copy_request = CopyRequest.new
    @copy_request.user = current_user
  end

  def edit
  end

  def create
    @copy_request = CopyRequest.new(params[:copy_request])
    respond_to do |format|
      if @copy_request.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.copy_request'))
        format.html { redirect_to(@copy_request) }
        format.json { render :json => @copy_request, :status => :created, :location => @copy_request }
      else
        format.html { render :action => "new" }
        format.json { render :json => @area.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @copy_request = CopyRequest.find(params[:id])

    respond_to do |format|
      if @copy_request.update_attributes(params[:copy_request])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.copy_request'))
        format.html { redirect_to(@copy_request) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @copy_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @copy_request = CopyRequest.find(params[:id])
    @copy_request.destroy
    respond_to do |format|
      format.html { redirect_to(copy_requests_url) }
    end
  end 

  private
  def use_copy_request?
    access_denied unless SystemConfiguration.get('use_copy_request')
  end
end
