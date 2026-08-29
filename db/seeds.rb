owner = User.find_or_create_by!(email_address: "owner@mykiosk.test") do |user|
  user.password = "kiosk1234"
  user.phone_number = "9000000001"
end
owner.update!(owner: true)

[
  [ "Tomato", 30, "kg", 50 ], [ "Potato", 25, "kg", 80 ], [ "Onion", 35, "kg", 60 ],
  [ "Spinach", 20, "bunch", 30 ], [ "Carrot", 45, "kg", 25 ], [ "Cauliflower", 40, "piece", 20 ],
  [ "Green Chilli", 15, "100g", 40 ], [ "Coriander", 10, "bunch", 35 ],
  [ "Brinjal", 38, "kg", 22 ], [ "Lady Finger", 42, "kg", 18 ]
].each do |name, price, unit, stock|
  Product.find_or_initialize_by(name:).update!(price:, unit:, stock:)
end
