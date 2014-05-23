class MyAccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user

    respond_to do |format|
      format.html
      format.json { render :json => @user }
    end
  end

  def edit
    @user = current_user
    if defined?(EnjuCirculation)
      if params[:mode] == 'feed_token'
        if params[:disable] == 'true'
          @user.delete_checkout_icalendar_token
        else
          @user.reset_checkout_icalendar_token
        end
        render :partial => 'feed_token'
        return
      end
    end
    prepare_options
  end

  def update
    @user = current_user

    respond_to do |format|
      if current_user.has_role?('Librarian')
        saved = current_user.update_with_password(user_params) #, :as => :admin)
      else
        saved = current_user.update_with_password(user_params)
      end

      if saved
        sign_in(current_user, :bypass => true)
        format.html { redirect_to my_account_url, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user')) }
        format.json { head :no_content }
      else
        @user = current_user
        prepare_options
        format.html { render :action => 'edit' }
        format.json { render :json => current_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to my_account_url, :notice => 'devise.registrations.destroyed' }
      format.json { head :no_content }
    end
  end

  private
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

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password,
      :remember_me, :email_confirmation, :library_id, :locale,
      :keyword_list, :auto_generated_password
    )
  end
end
