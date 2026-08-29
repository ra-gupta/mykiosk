class OrdersController < ApplicationController
  def index
    @orders = Current.user.orders.order(created_at: :desc)
  end

  def show
    @order = Current.user.orders.find(params[:id])
  end

  def new
    return redirect_to cart_path, alert: "Your basket is empty." if cart.empty?

    @order = Order.new(phone_number: Current.user.phone_number, state: "Karnataka")
  end

  def create
    @order = Order.place!(user: Current.user, details: order_params, cart: cart)
    session[:cart] = {}
    redirect_to @order, notice: "Order placed."
  rescue ActiveRecord::RecordInvalid => e
    @order = e.record
    render :new, status: :unprocessable_entity
  end

  private
    def order_params = params.require(:order).permit(*Order::FIELDS)
end
