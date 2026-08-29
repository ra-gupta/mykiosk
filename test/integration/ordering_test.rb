require "test_helper"

class OrderingTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "shopper@example.com", password: "secret123")
    @tomato = Product.create!(name: "Tomato", price: 30, unit: "kg", stock: 5)
  end

  test "web: browse, fill basket, checkout, and see the order" do
    post session_path, params: { email_address: @user.email_address, password: "secret123" }
    patch cart_item_path(@tomato), params: { quantity: 2 }
    post orders_path, params: { address: "12 Market Rd" }

    order = @user.orders.sole
    assert_equal 60, order.total
    assert_equal 3, @tomato.reload.stock
    assert_empty session[:cart]

    get order_path(order)
    assert_select "h1", "Order ##{order.id}"
  end

  test "cart quantity is capped at available stock" do
    patch cart_item_path(@tomato), params: { quantity: 99 }
    get cart_path
    assert_select "td", text: "₹150.00"
  end

  test "api: sign in, place an order, list orders" do
    post api_v1_session_path, params: { email_address: @user.email_address, password: "secret123" }
    token = response.parsed_body["token"]
    headers = { "Authorization" => "Bearer #{token}" }

    post api_v1_orders_path, headers: headers,
      params: { address: "12 Market Rd", items: [ { product_id: @tomato.id, quantity: 2 } ] }
    assert_response :created
    assert_equal "60.0", response.parsed_body["total"]

    get api_v1_orders_path, headers: headers
    assert_equal 1, response.parsed_body.size
    get api_v1_orders_path
    assert_response :unauthorized
  end

  test "api: ordering more than the stock leaves stock untouched" do
    post api_v1_session_path, params: { email_address: @user.email_address, password: "secret123" }
    post api_v1_orders_path, headers: { "Authorization" => "Bearer #{response.parsed_body["token"]}" },
      params: { address: "12 Market Rd", items: [ { product_id: @tomato.id, quantity: 99 } ] }

    assert_response :unprocessable_entity
    assert_equal 5, @tomato.reload.stock
    assert_equal 0, Order.count
  end
end
