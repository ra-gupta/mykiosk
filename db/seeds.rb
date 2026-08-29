owner = User.find_or_create_by!(email_address: "owner@mykiosk.test") do |user|
  user.password = "kiosk1234"
  user.phone_number = "9000000001"
end
owner.update!(owner: true)

# name, unit, price, mrp, stock, image
[
  [ "Tomato", "1 kg", 30, 36, 50, "tomato" ],
  [ "Potato", "1 kg", 25, 31, 80, "potato" ],
  [ "Onion", "1 kg", 35, 49, 60, "onion" ],
  [ "Spinach (Palak)", "250 g", 20, 26, 30, "spinach" ],
  [ "Carrot", "500 g", 45, 52, 25, "carrot" ],
  [ "Cauliflower", "1 piece", 40, 48, 20, "cauliflower" ],
  [ "Green Chilli", "100 g", 13, 15, 40, "green-chilli" ],
  [ "Coriander (Dhaniya)", "100 g", 10, 14, 35, "coriander" ],
  [ "Brinjal", "500 g", 38, 44, 22, "brinjal" ],
  [ "Lady Finger (Bhendi)", "250 g", 18, 22, 18, "lady-finger" ],
  [ "Banana (Robusta)", "6 pieces", 42, 55, 40, "banana" ],
  [ "Apple (Shimla)", "4 pieces", 120, 149, 24, "apple" ],
  [ "Mango (Alphonso)", "1 kg", 210, 260, 15, "mango" ],
  [ "Orange (Nagpur)", "1 kg", 95, 120, 0, "orange" ]
].each do |name, unit, price, mrp, stock, image|
  Product.find_or_initialize_by(name:).update!(price:, mrp:, unit:, stock:, image: "products/#{image}.jpg")
end
