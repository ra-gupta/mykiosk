require "test_helper"

class OwnerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email_address: "owner@example.com", password: "secret123", owner: true)
    @shopper = User.create!(phone_number: "9876543210")
    @product = Product.create!(name: "Tomato", price: 30, unit: "1 kg", stock: 5)
    @order = Order.place!(user: @shopper, details: address_attributes, cart: { @product.id.to_s => 1 })
  end

  test "the owner takes an item off the shelf and puts it back" do
    sign_in_as @owner

    patch owner_product_path(@product, product: { stock: 0 })
    assert_equal 0, @product.reload.stock

    patch owner_product_path(@product, product: { stock: 12, price: 34 })
    assert_equal [ 12, 34 ], @product.reload.then { |p| [ p.stock, p.price.to_i ] }
  end

  test "the owner walks an order from placed to delivered" do
    sign_in_as @owner

    Order::NEXT_STATUS.each_value do |status|
      patch owner_order_path(@order, status:)
      assert_equal status, @order.reload.status
    end
    assert_equal "delivered", @order.status
  end

  test "a shopper cannot see or touch the owner screens" do
    sign_in_as @shopper, code: User.start_phone_verification(@shopper.phone_number).otp

    get owner_orders_path
    assert_redirected_to root_path

    patch owner_order_path(@order, status: "delivered")
    assert_equal "placed", @order.reload.status
  end

  test "cancelling an order puts its items back on the shelf" do
    sign_in_as @owner

    patch owner_order_path(@order, status: "cancelled")
    assert_equal 5, @product.reload.stock
  end

  test "api: the owner sees every order with the customer's name and moves it along" do
    post api_v1_session_path, params: { email_address: @owner.email_address, password: "secret123" }
    assert response.parsed_body.dig("user", "owner")
    headers = { "Authorization" => "Bearer #{response.parsed_body["token"]}" }

    get api_v1_owner_orders_path, headers: headers
    order = response.parsed_body.sole
    assert_equal [ @shopper.phone_number, "In 30 minutes", "packed" ],
      order.values_at("customer_name", "delivery_promise", "next_status")

    patch api_v1_owner_order_path(@order), headers: headers, params: { status: "packed" }
    assert_equal "packed", response.parsed_body["status"]

    patch api_v1_owner_product_path(@product), headers: headers, params: { product: { stock: 0 } }
    assert_equal 0, @product.reload.stock
    assert_match %r{^http://.+/products/}, response.parsed_body["image_url"].to_s if @product.image.present?
  end

  test "api: a shopper is refused the owner endpoints" do
    code = User.start_phone_verification(@shopper.phone_number).otp
    post api_v1_session_path, params: { phone_number: @shopper.phone_number, code: }
    assert_not response.parsed_body.dig("user", "owner")

    get api_v1_owner_orders_path, headers: { "Authorization" => "Bearer #{response.parsed_body["token"]}" }
    assert_response :forbidden
  end

  private
    def sign_in_as(user, code: nil)
      credentials = code ? { phone_number: user.phone_number, code: } :
                           { email_address: user.email_address, password: "secret123" }
      post session_path, params: credentials
    end
end
