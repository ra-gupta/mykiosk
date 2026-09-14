module Api
  module V1
    module Owner
      class OrdersController < BaseController
        def index
          orders = Order.includes(:user, order_items: :product).order(created_at: :desc).limit(100)
          orders = orders.where(status: params[:status]) if params[:status].present?
          render json: orders.map { |order| order_json(order) }
        end

        # { status: "packed" | "out_for_delivery" | "delivered" | "cancelled" }
        def update
          order = Order.find(params[:id])
          order.update!(status: params.require(:status))
          render json: order_json(order)
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
