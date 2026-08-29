class OrdersController < ApplicationController
  def index
    @orders = Current.user.orders.order(created_at: :desc)
  end

  def show
    @order = Current.user.orders.find(params[:id])
  end

  def new
    return redirect_to cart_path, alert: "Your basket is empty." if cart.empty?

    previous = Current.user.orders.last
    @order = Order.new(previous&.slice(*Order::FIELDS) ||
      { phone_number: Current.user.phone_number, state: "Karnataka" })
  end

  def create
    @order = Order.place!(user: Current.user, details: order_params, cart: cart)
    session[:cart] = {}
    redirect_to @order, notice: "Order placed."
  rescue ActiveRecord::RecordInvalid => e
    @order = e.record
    render :new, status: :unprocessable_entity
  end

  def reorder
    order = Current.user.orders.find(params[:id])
    session[:cart] = order.to_cart

    if cart.empty?
      redirect_to orders_path, alert: "Nothing from that order is in stock today."
    else
      redirect_to cart_path, notice: "Basket refilled from order ##{order.id}."
    end
  end

  private
    def order_params = params.require(:order).permit(*Order::FIELDS)
end
