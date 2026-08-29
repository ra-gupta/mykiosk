require "test_helper"

class OrderAlertJobTest < ActiveJob::TestCase
  setup do
    @owner = User.create!(email_address: "owner@example.com", password: "secret123",
      phone_number: "9000000001", owner: true)
    @shopper = User.create!(phone_number: "9876543210")
    DeviceToken.register(@owner, "owner-device")
    DeviceToken.register(@shopper, "shopper-device")
    @product = Product.create!(name: "Tomato", price: 30, unit: "1 kg", stock: 5)
  end

  test "a placed order alerts the owner, not the shopper" do
    assert_enqueued_with(job: OrderAlertJob, args: ->(args) { args.last == "owner" }) do
      place_order
    end
    assert_equal [ "owner-device" ], DeviceToken.owners.pluck(:token)

    perform_enqueued_jobs
  end

  test "the owner also gets a text with the order on it" do
    text = texts_from { place_order }.sole

    assert_equal @owner.phone_number, text.first
    assert_match(/new order #\d+ for ₹30.00, in 30 minutes, to Rahul Gupta in Bengaluru/, text.last)
  end

  test "an owner without a phone number is only pushed to" do
    @owner.update!(phone_number: nil)

    assert_empty texts_from { place_order }
  end

  test "moving an order along alerts the shopper, and only on a status change" do
    order = place_order

    assert_enqueued_with(job: OrderAlertJob, args: ->(args) { args.last == "customer" }) do
      order.update!(status: "out_for_delivery")
    end
    assert_equal "Your order is on the way.", Order::CUSTOMER_PUSH[order.status]

    assert_no_enqueued_jobs(only: OrderAlertJob) { order.update!(total: 31) }

    perform_enqueued_jobs
  end

  private
    def place_order
      Order.place!(user: @shopper, details: address_attributes, cart: { @product.id.to_s => 1 })
    end

    # Runs the alert job so the SMS jobs it enqueues can be read off the queue.
    def texts_from
      perform_enqueued_jobs(only: OrderAlertJob) { yield }
      enqueued_jobs.filter_map { |job| job["arguments"] if job["job_class"] == "SmsJob" }
    end
end
