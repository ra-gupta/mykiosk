class OwnerController < ApplicationController
  before_action :require_owner

  def orders
    @orders = Order.includes(:user, order_items: :product).order(created_at: :desc).limit(50)
  end

  private
    def require_owner
      redirect_to root_path, alert: "Owners only." unless Current.user&.owner?
    end
end
