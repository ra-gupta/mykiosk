require "application_system_test_case"

class ShoppingTest < ApplicationSystemTestCase
  setup do
    @owner = User.create!(email_address: "owner@mykiosk.test", password: "kiosk1234", owner: true)
    Product.create!(name: "Tomato", price: 30, unit: "kg", stock: 20)
    Product.create!(name: "Spinach", price: 20, unit: "bunch", stock: 12)
    Product.create!(name: "Carrot", price: 45, unit: "kg", stock: 0)
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
    shot "05-checkout"
    click_on "Place order (cash on delivery)"
    assert_text "Order placed."
    shot "06-order-placed"

    click_on "Sign out"
    fill_in "email_address", with: @owner.email_address
    fill_in "password", with: "kiosk1234"
    within("main") { click_on "Sign in" }
    click_on "Incoming"
    assert_text "Indiranagar"
    shot "07-owner-incoming"
  end

  private
    def shot(name) = save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png"))
end
