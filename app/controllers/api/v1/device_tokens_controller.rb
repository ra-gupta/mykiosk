module Api
  module V1
    class DeviceTokensController < BaseController
      def create
        DeviceToken.register(Current.user, params.require(:token))
        head :created
      end

      def destroy
        Current.user.device_tokens.find_by(token: params[:id])&.destroy
        head :no_content
      end
    end
  end
end
