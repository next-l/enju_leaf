class MyAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show
    respond_to do |format|
      format.html
      format.json { render json: @profile }
    end
  end

  def edit
    prepare_options
  end

  def update
    user_attrs = [
      :id, :email, :current_password, :password, :password_confirmation
    ]
    user_attrs += [
      {:user_has_role_attributes => [:id, :role_id]}
    ] if current_user.has_role?('Administrator')

    user_params = ActionController::Parameters.new(params[:profile][:user_attributes]).permit(*user_attrs)

    respond_to do |format|
      saved = current_user.update_attributes(user_params)
      @profile.assign_attributes(profile_params)

      if saved
        if @profile.save
          sign_in(current_user, bypass: true)
          format.html { redirect_to my_account_url, notice: t('controller.successfully_updated', model: t('activerecord.models.user')) }
          format.json { head :no_content }
        else
          prepare_options
          format.html { render action: "edit" }
          format.json { render json: current_user.errors, status: :unprocessable_entity }
        end
      else
        current_user.errors.full_messages.each do |msg|
          @profile.errors[:base] << msg
        end
        prepare_options
        format.html { render action: "edit" }
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
      :full_name, :full_name_transcription, :user_number,
      :library_id, :keyword_list, :note,
      :locale, :required_role_id, :expired_at,
      :locked, :birth_date,
      :save_checkout_history, :checkout_icalendar_token, # EnjuCirculation
      :save_search_history # EnjuSearchLog
    ]
    if current_user.has_role?('Librarian')
      attrs << :user_group_id
    end
    params.require(:profile).permit(*attrs)
  end

  def prepare_options
    @user_groups = UserGroup.order(:position)
    @roles = Role.order(:position)
    @libraries = Library.order(:position)
    @languages = Language.order(:position)
    if current_user.active_for_authentication?
      current_user.locked = '0'
    else
      current_user.locked = '1'
    end
  end
end
