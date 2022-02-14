class MyAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show
    respond_to do |format|
      format.html
      format.html.phone
      format.json { render json: @profile }
    end
  end

  def edit
    prepare_options
  end

  def update
    respond_to do |format|
      @profile.assign_attributes(profile_update_params)

      if @profile.save
        bypass_sign_in(current_user)
        format.html { redirect_to my_account_url, notice: t('controller.successfully_updated', model: t('activerecord.models.user')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: 'edit' }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to my_account_url, notice: 'devise.registrations.destroyed' }
      format.json { head :no_content }
    end
  end

  private

  def set_profile
    @profile = current_user.profile
    authorize @profile
  end

  def profile_params
    attrs = [
      :full_name, :full_name_transcription,
      :library_id, :keyword_list, :note,
      :locale, :required_role_id,
      :locked, :birth_date,
      :save_checkout_history, :checkout_icalendar_token, # EnjuCirculation
      :save_search_history, { # EnjuSearchLog
        user_attributes: [
          :id, :username, :email, :locked,
          { user_has_role_attributes: [:id, :role_id] }
        ]
      }
    ]
    attrs << :user_group_id if current_user.has_role?('Librarian')
    params.require(:profile).permit(*attrs)
  end

  def profile_update_params
    attrs = [
      :full_name, :full_name_transcription,
      :keyword_list, :locale,
      :save_checkout_history, :checkout_icalendar_token, # EnjuCirculation
      :save_search_history, # EnjuSearchLog
    ]
    if current_user.has_role?('Librarian')
      attrs += [
        :library_id, :expired_at, :birth_date,
        :user_group_id, :required_role_id, :note, :user_number, {
          user_attributes: [
            :id, :email, :locked,
            { user_has_role_attributes: [:id, :role_id] }
          ]
        }
      ]
    end
    params.require(:profile).permit(*attrs)
  end

  def prepare_options
    @user_groups = UserGroup.order(:position)
    @roles = Role.order(:position)
    @libraries = Library.order(:position)
    @languages = Language.order(:position)
    current_user.locked = if current_user.active_for_authentication?
                            '0'
                          else
                            '1'
    end
  end
end
