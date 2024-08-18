class TwoFactorAuthenticationsController < ApplicationController
  before_action :skip_authorization
  
  def show
  end

  def create
    current_user.update!(
      otp_secret: User.generate_otp_secret
    )

    redirect_to two_factor_authentication_url
  end

  def destroy
    current_user.update!(
      otp_secret: nil,
      otp_required_for_login: false
    )
    redirect_to two_factor_authentication_url
  end
end
