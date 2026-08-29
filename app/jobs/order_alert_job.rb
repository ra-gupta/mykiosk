class OrderAlertJob < ApplicationJob
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer

  def perform(order, audience)
    case audience
    when "owner" then alert_owners(order)
    when "customer" then alert_customer(order)
    end
  end

  private
    def alert_owners(order)
      Fcm.notify(DeviceToken.owners.pluck(:token), title: "New order ##{order.id}",
        body: "#{rupees(order.total)} · #{order.delivery_promise}", data: { order_id: order.id })

      User.owners_with_phone.each do |owner|
        SmsJob.perform_later(owner.phone_number, "MyKiosk: new order ##{order.id} for #{rupees(order.total)}, " \
          "#{order.delivery_promise.downcase}, to #{order.recipient_name} in #{order.city}.")
      end
    end

    def alert_customer(order)
      body = Order::CUSTOMER_PUSH[order.status] or return

      Fcm.notify(order.user.device_tokens.pluck(:token), title: "Order ##{order.id}", body:,
        data: { order_id: order.id })
    end

    def rupees(amount) = ActionController::Base.helpers.number_to_currency(amount, unit: "₹")
end
