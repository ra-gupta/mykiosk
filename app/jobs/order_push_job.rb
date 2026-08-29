class OrderPushJob < ApplicationJob
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer

  def perform(order, audience)
    tokens, title, body = case audience
    when "owner"
      [ DeviceToken.owners.pluck(:token), "New order ##{order.id}",
        "#{rupees(order.total)} · #{order.delivery_promise}" ]
    when "customer"
      [ order.user.device_tokens.pluck(:token), "Order ##{order.id}", Order::CUSTOMER_PUSH[order.status] ]
    end

    Fcm.notify(tokens, title:, body:, data: { order_id: order.id }) if body
  end

  private
    def rupees(amount) = ActionController::Base.helpers.number_to_currency(amount, unit: "₹")
end
