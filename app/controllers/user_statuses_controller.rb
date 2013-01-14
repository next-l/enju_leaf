class UserStatusesController < ApplicationController
  load_and_authorize_resource

  def index
    @user_statuses = UserStatus.page(params[:page])
  end

  def create
    @user_status = UserStatus.new(params[:user_status])
      respond_to do |format|
      if @user_status.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.user_status'))
        format.html { redirect_to(@user_status) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @user_status = UserStatus.find(params[:id])
=begin
    if params[:move]
      move_position(@user_status, params[:move])
      return
    end
    update!
=end

    respond_to do |format|
      if @user_status.update_attributes(params[:user_status])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user_status'))
        format.html { redirect_to(@user_status) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @user_status = UserStatus.find(params[:id])
    @user_status.destroy
    respond_to do |format|
      format.html { redirect_to(user_statuses_url) }
    end
  end

end
