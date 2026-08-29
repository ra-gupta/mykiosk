require "test_helper"

class OrderingTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "shopper@example.com", password: "secret123")
    @tomato = Product.create!(name: "Tomato", price: 30, unit: "kg", stock: 5)
  end

  test "web: browse, fill basket, checkout, and see the order" do
    post session_path, params: { email_address: @user.email_address, password: "secret123" }
    patch cart_item_path(@tomato), params: { quantity: 2 }
    post orders_path, params: { order: address_attributes(delivery_option: "end_of_day") }

    order = @user.orders.sole
    assert_equal 60, order.total
    assert_equal "end_of_day", order.delivery_option
    assert_equal 3, @tomato.reload.stock
    assert_empty session[:cart]

    get order_path(order)
    assert_select "h1", "Order ##{order.id}"
    assert_select "address", /Indiranagar/
  end

  test "a second order prefills the address and can be refilled from the first" do
    post session_path, params: { email_address: @user.email_address, password: "secret123" }
    patch cart_item_path(@tomato), params: { quantity: 2 }
    post orders_path, params: { order: address_attributes }
    order = @user.orders.sole

    post reorder_order_path(order)
    assert_redirected_to cart_path
    assert_equal({ @tomato.id.to_s => 2 }, session[:cart])

    get new_order_path
    assert_select "input[name='order[line1]'][value=?]", address_attributes[:line1]

    @tomato.update!(stock: 0)
    post reorder_order_path(order)
    assert_redirected_to orders_path
    assert_empty session[:cart]
  end

  test "cart quantity is capped at available stock" do
    patch cart_item_path(@tomato), params: { quantity: 99 }
    get cart_path
    assert_select "[data-total]", text: "₹150.00"
  end

  test "api: sign in, place an order, list orders" do
    post api_v1_session_path, params: { email_address: @user.email_address, password: "secret123" }
    token = response.parsed_body["token"]
    headers = { "Authorization" => "Bearer #{token}" }

    post api_v1_orders_path, headers: headers,
      params: { address: address_attributes, items: [ { product_id: @tomato.id, quantity: 2 } ] }
    assert_response :created
    assert_equal "instant", response.parsed_body["delivery_option"]
    assert_equal "60.0", response.parsed_body["total"]

    get api_v1_orders_path, headers: headers
    assert_equal 1, response.parsed_body.size
    get api_v1_orders_path
    assert_response :unauthorized
  end

  test "api: ordering more than the stock leaves stock untouched" do
    post api_v1_session_path, params: { email_address: @user.email_address, password: "secret123" }
    post api_v1_orders_path, headers: { "Authorization" => "Bearer #{response.parsed_body["token"]}" },
      params: { address: address_attributes, items: [ { product_id: @tomato.id, quantity: 99 } ] }

    assert_response :unprocessable_entity
    assert_equal 5, @tomato.reload.stock
    assert_equal 0, Order.count
  end
end
