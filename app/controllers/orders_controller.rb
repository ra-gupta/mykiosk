class OrdersController < ApplicationController
  def index
    @orders = Current.user.orders.order(created_at: :desc)
  end

  def show
    @order = Current.user.orders.find(params[:id])
  end

  def new
    redirect_to cart_path, alert: "Your cart is empty." if cart.empty?
  end

  def create
    @order = Order.place!(user: Current.user, address: params[:address], cart: cart)
    session[:cart] = {}
    redirect_to @order, notice: "Order placed."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path, alert: e.record.errors.full_messages.to_sentence
  end
end
