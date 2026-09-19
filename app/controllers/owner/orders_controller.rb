module Owner
  class OrdersController < BaseController
    def index
      @orders = Order.includes(:user, order_items: :product).order(created_at: :desc).limit(50)
    end

    def update
      order = Order.find(params[:id])

      if order.update(status: params[:status])
        redirect_to owner_orders_path, notice: "Order ##{order.id} is #{order.status.humanize.downcase}."
      else
        redirect_to owner_orders_path, alert: order.errors.full_messages.to_sentence
      end
    end
  end
end
