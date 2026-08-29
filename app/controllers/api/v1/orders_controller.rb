module Api
  module V1
    class OrdersController < BaseController
      def index
        render json: Current.user.orders.order(created_at: :desc).as_json(only: order_fields)
      end

      def show
        render json: order_json(Current.user.orders.find(params[:id]))
      end

      # { address: { recipient_name:, phone_number:, pincode:, line1:, line2:, landmark:, city:, state: },
      #   delivery_option: "instant" | "end_of_day", items: [ { product_id:, quantity: } ] }
      def create
        cart = params.require(:items).to_h { |item| [ item[:product_id].to_s, item[:quantity].to_i ] }
        details = params.require(:address).permit(*Order::ADDRESS_FIELDS)
          .merge(delivery_option: params[:delivery_option])
        order = Order.place!(user: Current.user, cart:, details:)
        render json: order_json(order), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private
        def order_fields = %i[ id status total created_at ] + Order::FIELDS

        def order_json(order)
          order.as_json(only: order_fields).merge(
            items: order.order_items.map { |item|
              { product_id: item.product_id, name: item.product.name, quantity: item.quantity, price: item.price }
            }
          )
        end
    end
  end
end
