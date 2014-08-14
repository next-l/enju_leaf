class MyAccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @profile = current_user.profile

    respond_to do |format|
      format.html
      format.json { render json: @profile }
    end
  end

  def edit
    @profile = current_user.profile
    if defined?(EnjuCirculation)
      if params[:mode] == 'feed_token'
        if params[:disable] == 'true'
          @profile.delete_checkout_icalendar_token
        else
          @profile.reset_checkout_icalendar_token
        end
        render partial: 'feed_token'
        return
      end
    end
    prepare_options
  end

  def update
    @profile = current_user.profile

    respond_to do |format|
      if current_user.has_role?('Librarian')
        saved = current_user.update_with_password(params[:profile][:user_attributes], as: :admin)
        @profile.assign_attributes(params[:profile], as: :admin)
      else
        saved = current_user.update_with_password(params[:profile][:user_attributes])
        @profile.assign_attributes(params[:profile])
      end

      if saved
        if @profile.save
          sign_in(current_user, :bypass => true)
          format.html { redirect_to my_account_url, notice: t('controller.successfully_updated', model: t('activerecord.models.user')) }
          format.json { head :no_content }
        else
          prepare_options
          format.html { render action: "edit" }
          format.json { render json: current_user.errors, status: :unprocessable_entity }
        end
      else
        @profile.errors[:base] << I18n.t('activerecord.attributes.user.current_password')
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile = current_user.profile
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to my_account_url, notice: 'devise.registrations.destroyed' }
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
end
