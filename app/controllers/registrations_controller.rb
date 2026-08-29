class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.permit(:email_address, :password, :password_confirmation))

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Welcome!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
