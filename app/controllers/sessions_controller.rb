class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @otp_phone = session[:otp_phone]
  end

  def create
    if user = User.authenticate(params.permit(:email_address, :password, :phone_number, :code))
      session.delete(:otp_phone)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Those sign in details didn't work. Try again."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
