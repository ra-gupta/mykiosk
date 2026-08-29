require "application_system_test_case"

class ShoppingTest < ApplicationSystemTestCase
  setup do
    @owner = User.create!(email_address: "owner@mykiosk.test", password: "kiosk1234", owner: true)
    Product.create!(name: "Tomato", price: 30, mrp: 36, unit: "1 kg", stock: 20, image: "products/tomato.jpg")
    Product.create!(name: "Spinach (Palak)", price: 20, mrp: 26, unit: "250 g", stock: 12, image: "products/spinach.jpg")
    Product.create!(name: "Carrot", price: 45, mrp: 52, unit: "500 g", stock: 0, image: "products/carrot.jpg")
  end

  test "shopping with an OTP sign in, then the owner watching it arrive" do
    visit root_path
    shot "01-catalog"

    within(".card", text: "Tomato") { click_on "Add" }
    within(".card", text: "Tomato") { click_on "+" }
    within("header") { click_on "Basket" }
    shot "02-cart"

    click_on "Checkout"
    fill_in "phone_number", with: "9876543210"
    shot "03-sign-in"
    click_on "Send OTP"
    shot "04-otp"

    fill_in "code", with: User.start_phone_verification("9876543210").otp
    click_on "Verify and continue"

    within("header") { click_on "Basket" }
    click_on "Checkout"
    attributes = address_attributes
    select attributes.delete(:state), from: "order_state"
    attributes.each { |field, value| fill_in "order_#{field}", with: value }
    choose "By 9 pm today"
    shot "05-checkout"
    click_on "Place order (cash on delivery)"
    assert_text "Order placed."
    shot "06-order-placed"

    click_on "Orders"
    click_on "Reorder"
    assert_text "Basket refilled"
    shot "10-reorder"
    click_on "Empty basket"

    click_on "Sign out"
    fill_in "email_address", with: @owner.email_address
    fill_in "password", with: "kiosk1234"
    within("main") { click_on "Sign in" }
    click_on "Incoming"
    assert_text "Indiranagar"
    assert_text "By 9 pm today"
    shot "07-owner-incoming"

    click_on "Mark packed"
    click_on "Mark out for delivery"
    assert_text "Out for delivery"
    click_on "Mark delivered"
    assert_text "Delivered"
    shot "08-owner-delivered"

    click_on "Shelf"
    within("[data-product='Spinach (Palak)']") { click_on "Out of stock" }
    assert_text "Out of stock"
    shot "09-owner-shelf"
  end

  private
    def shot(name) = save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png"))
end
