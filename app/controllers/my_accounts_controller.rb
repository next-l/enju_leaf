class MyAccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user

    respond_to do |format|
      format.html
      format.json { render :json => @user.to_json }
    end
  end

  def edit
    @user = current_user
    @user.role_id = @user.role.id
    prepare_options
  end

  def update
    current_user.update_with_params(params[:user], current_user)
    @user = current_user

    respond_to do |format|
      if current_user.update_with_password(params[:user])
        sign_in(current_user, :bypass => true)
        format.html { redirect_to(my_account_url, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user'))) }
        format.json { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => current_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(my_account_url, :notice => 'devise.registrations.destroyed') }
      format.json { head :ok }
    end
  end

  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all_cache
    @languages = Language.all_cache
    if current_user.active_for_authentication?
      current_user.locked = '0'
    else
      current_user.locked = '1'
    end
  end
end
