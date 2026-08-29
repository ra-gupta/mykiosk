class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :cart, :cart_count

  def cart
    session[:cart] ||= {}
  end

  def cart_count
    cart.values.sum(&:to_i)
  end
end
