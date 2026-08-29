class CartsController < ApplicationController
  allow_unauthenticated_access

  def show
  end

  def update
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i.clamp(0, product.stock)

    quantity.zero? ? cart.delete(product.id.to_s) : cart[product.id.to_s] = quantity
    session[:cart] = cart

    redirect_back fallback_location: cart_path
  end

  def destroy
    session[:cart] = {}
    redirect_to cart_path
  end
end
