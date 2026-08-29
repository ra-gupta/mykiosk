require "test_helper"

class OwnerPushJobTest < ActiveJob::TestCase
  test "a placed order enqueues one push aimed at the owner's devices" do
    owner = User.create!(email_address: "owner@example.com", password: "secret123", owner: true)
    shopper = User.create!(phone_number: "9876543210")
    DeviceToken.register(owner, "owner-device")
    DeviceToken.register(shopper, "shopper-device")
    product = Product.create!(name: "Tomato", price: 30, unit: "kg", stock: 5)

    assert_enqueued_with(job: OwnerPushJob) do
      Order.place!(user: shopper, details: address_attributes, cart: { product.id.to_s => 1 })
    end
    assert_equal [ "owner-device" ], DeviceToken.owners.pluck(:token)

    perform_enqueued_jobs
  end
end
