require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @shopper = User.create!(phone_number: "9876543210")
    @tomato = Product.create!(name: "Tomato", price: 30, unit: "1 kg", stock: 5)
    @order = Order.place!(user: @shopper, details: address_attributes, cart: { @tomato.id.to_s => 2 })
  end

  test "an order only moves forward, and delivered and cancelled are final" do
    assert_not @order.update(status: "delivered"), "placed can't skip to delivered"
    assert_match(/can't go from placed to delivered/, @order.errors.full_messages.to_sentence)

    @order.reload
    Order::NEXT_STATUS.each_value { |status| assert @order.update(status:), @order.errors.full_messages.to_sentence }
    assert @order.final?
    assert_not @order.update(status: "cancelled")
    assert_not @order.update(status: "placed")
  end

  test "cancelling puts the stock back exactly once" do
    assert_equal 3, @tomato.reload.stock

    assert @order.update(status: "cancelled")
    assert_equal 5, @tomato.reload.stock

    assert_not @order.update(status: "packed"), "cancelled is final"
    assert_equal 5, @tomato.reload.stock
  end

  test "placing an order takes stock atomically and rolls everything back when one item is short" do
    onion = Product.create!(name: "Onion", price: 35, unit: "1 kg", stock: 1)

    assert_raises(ActiveRecord::RecordInvalid) do
      Order.place!(user: @shopper, details: address_attributes, cart: { @tomato.id.to_s => 1, onion.id.to_s => 2 })
    end
    assert_equal [ 3, 1 ], [ @tomato.reload.stock, onion.reload.stock ]
    assert_equal 1, Order.count
  end

  test "a product that has been ordered can't be deleted, only taken off the shelf" do
    assert_not @tomato.destroy
    assert_match(/order items/i, @tomato.errors.full_messages.to_sentence)
    assert Product.exists?(@tomato.id)
  end
end
