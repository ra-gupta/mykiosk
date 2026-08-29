class PhoneVerificationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 3.minutes, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def create
    @user = User.start_phone_verification(params[:phone_number])
  rescue ActiveRecord::RecordInvalid
    redirect_to new_session_path, alert: "Enter a valid 10 digit mobile number."
  end
end
