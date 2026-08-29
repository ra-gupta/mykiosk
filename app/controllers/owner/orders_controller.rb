module Owner
  class OrdersController < BaseController
    def index
      @orders = Order.includes(:user, order_items: :product).order(created_at: :desc).limit(50)
    end

    def update
      order = Order.find(params[:id])
      order.update!(status: params[:status])

      redirect_to owner_orders_path, notice: "Order ##{order.id} is #{order.status.humanize.downcase}."
    end
  end
end
