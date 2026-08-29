class OwnerPushJob < ApplicationJob
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer

  def perform(order)
    Fcm.notify(DeviceToken.owners.pluck(:token),
      title: "New order ##{order.id}",
      body: "#{ActionController::Base.helpers.number_to_currency(order.total, unit: '₹')} · #{order.user.display_name}",
      data: { order_id: order.id })
  end
end
