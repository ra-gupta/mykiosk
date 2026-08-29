module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate, only: :create
      rate_limit to: 10, within: 3.minutes, only: :create

      def create
        user = User.authenticate(params.permit(:email_address, :password, :phone_number, :code))
        return render json: { error: "Invalid credentials" }, status: :unauthorized unless user

        session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
        render json: { token: session.token, user: { id: user.id, email_address: user.email_address } }, status: :created
      end

      def destroy
        Current.session.destroy
        head :no_content
      end
    end
  end
end
