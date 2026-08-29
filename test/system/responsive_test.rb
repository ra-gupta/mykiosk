require "application_system_test_case"

class ResponsiveTest < ApplicationSystemTestCase
  SIZES = { "phone" => [ 390, 844 ], "tablet" => [ 820, 1180 ], "desktop" => [ 1440, 900 ] }

  setup do
    @owner = User.create!(email_address: "owner@mykiosk.test", password: "kiosk1234", owner: true)
    Product.create!(name: "Tomato", price: 30, mrp: 36, unit: "1 kg", stock: 20, image: "products/tomato.jpg")
    Product.create!(name: "Spinach (Palak)", price: 20, mrp: 26, unit: "250 g", stock: 12, image: "products/spinach.jpg")
    Product.create!(name: "Carrot", price: 45, mrp: 52, unit: "500 g", stock: 0, image: "products/carrot.jpg")
    @order = Order.place!(user: @owner, details: address_attributes, cart: { Product.first.id.to_s => 2 })
  end

  test "no screen scrolls sideways on a phone, a tablet or a desktop" do
    visit new_session_path
    fill_in "email_address", with: @owner.email_address
    fill_in "password", with: "kiosk1234"
    within("main") { click_on "Sign in" }
    within(".card", text: "Tomato") { click_on "Add" }

    SIZES.each do |size, (width, height)|
      page.driver.browser.manage.window.resize_to(width, height)

      { "catalog" => root_path, "basket" => cart_path, "checkout" => new_order_path,
        "orders" => orders_path, "receipt" => order_path(@order),
        "incoming" => owner_orders_path, "shelf" => owner_products_path }.each do |name, path|
        visit path
        save_screenshot Rails.root.join("tmp/screenshots/#{size}-#{name}.png")

        assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth + 1"),
          "#{name} scrolls sideways at #{width}px"
      end
    end
  end
end
