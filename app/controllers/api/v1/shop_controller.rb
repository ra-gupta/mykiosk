module Api
  module V1
    # What the app shows on its front door. SHOP_NAME is per deployment, so one
    # build of the app serves any shop.
    class ShopController < BaseController
      skip_before_action :authenticate

      def show
        render json: { name: ENV.fetch("SHOP_NAME", "MyKiosk"), delivery_options: Order::DELIVERY_OPTIONS }
      end
    end
  end
end
