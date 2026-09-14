module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate

      def create
        user = User.new(params.permit(:email_address, :password, :password_confirmation))
        return render json: { errors: user.errors.full_messages }, status: :unprocessable_entity unless user.save

        session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
        render json: session_json(session), status: :created
      end
    end
  end
end
