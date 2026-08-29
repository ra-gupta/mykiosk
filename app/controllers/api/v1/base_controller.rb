module Api
  module V1
    # Android sends `Authorization: Bearer <token>` from POST /api/v1/session.
    class BaseController < ActionController::API
      before_action :authenticate

      private
        def authenticate
          Current.session = Session.find_by(token: request.headers["Authorization"]&.remove("Bearer "))
          render json: { error: "Unauthorized" }, status: :unauthorized unless Current.session
        end
    end
  end
end
