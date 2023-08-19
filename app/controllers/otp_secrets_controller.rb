class OtpSecretsController < ApplicationController
  before_action :skip_authorization
  
  def create
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.update!(
        otp_required_for_login: true
      )
    end

    redirect_to two_factor_authentication_url
  end
end
