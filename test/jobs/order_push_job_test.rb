require "test_helper"

class OrderPushJobTest < ActiveJob::TestCase
  setup do
    @owner = User.create!(email_address: "owner@example.com", password: "secret123", owner: true)
    @shopper = User.create!(phone_number: "9876543210")
    DeviceToken.register(@owner, "owner-device")
    DeviceToken.register(@shopper, "shopper-device")
    @product = Product.create!(name: "Tomato", price: 30, unit: "1 kg", stock: 5)
  end

  test "a placed order pushes to the owner's devices, not the shopper's" do
    assert_enqueued_with(job: OrderPushJob, args: ->(args) { args.last == "owner" }) do
      place_order
    end
    assert_equal [ "owner-device" ], DeviceToken.owners.pluck(:token)

    perform_enqueued_jobs
  end

  test "moving an order along pushes to the shopper, and only on a status change" do
    order = place_order

    assert_enqueued_with(job: OrderPushJob, args: ->(args) { args.last == "customer" }) do
      order.update!(status: "out_for_delivery")
    end
    assert_equal "Your order is on the way.", Order::CUSTOMER_PUSH[order.status]

    assert_no_enqueued_jobs(only: OrderPushJob) { order.update!(total: 31) }

    perform_enqueued_jobs
  end

  private
    def place_order
      Order.place!(user: @shopper, details: address_attributes, cart: { @product.id.to_s => 1 })
    end
end
