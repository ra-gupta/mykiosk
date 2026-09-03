class Order < ApplicationRecord
  STATUSES = %w[ placed packed out_for_delivery delivered cancelled ]
  NEXT_STATUS = { "placed" => "packed", "packed" => "out_for_delivery", "out_for_delivery" => "delivered" }.freeze
  ADDRESS_FIELDS = %i[ recipient_name phone_number pincode line1 line2 landmark city state ]
  DELIVERY_OPTIONS = { "instant" => "In 30 minutes", "end_of_day" => "By 9 pm today" }.freeze
  CUSTOMER_PUSH = {
    "packed" => "We are packing your vegetables now.",
    "out_for_delivery" => "Your order is on the way.",
    "delivered" => "Delivered. Enjoy!",
    "cancelled" => "Your order was cancelled. Call the kiosk if that looks wrong."
  }.freeze
  FIELDS = ADDRESS_FIELDS + %i[ delivery_option ]
  STATES = [
    "Andaman and Nicobar Islands", "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chandigarh",
    "Chhattisgarh", "Dadra and Nagar Haveli and Daman and Diu", "Delhi", "Goa", "Gujarat", "Haryana",
    "Himachal Pradesh", "Jammu and Kashmir", "Jharkhand", "Karnataka", "Kerala", "Ladakh", "Lakshadweep",
    "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Puducherry",
    "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand",
    "West Bengal"
  ].freeze

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :recipient_name, :line1, :line2, :city, presence: true
  validates :state, inclusion: { in: STATES, message: "is not a state we deliver to" }
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be 6 digits" }
  validates :phone_number, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
  validates :status, inclusion: { in: STATUSES }
  validates :delivery_option, inclusion: { in: DELIVERY_OPTIONS.keys }

  after_create_commit -> { broadcast_prepend_to "incoming_orders", target: "incoming_orders" }
  after_create_commit -> { OrderAlertJob.perform_later(self, "owner") }
  after_update_commit -> { broadcast_replace_to "incoming_orders" }
  after_update_commit -> { OrderAlertJob.perform_later(self, "customer") if saved_change_to_status? }

  # ponytail: leans on SQLite's single-writer transaction instead of row locks;
  # add `Product.lock` if this moves to Postgres/MySQL.
  def self.place!(user:, details:, cart:)
    transaction do
      order = new(details.to_h.symbolize_keys.slice(*FIELDS).compact_blank.merge(user:, total: 0))
      total = 0

      cart.each do |product_id, quantity|
        product = Product.find_by(id: product_id)
        quantity = quantity.to_i

        if product.nil? || quantity <= 0 || quantity > product.stock
          order.errors.add(:base, "#{product&.name || "An item"} is no longer available in that quantity")
          raise ActiveRecord::RecordInvalid.new(order)
        end

        product.update!(stock: product.stock - quantity)
        order.order_items.build(product:, quantity:, price: product.price)
        total += product.price * quantity
      end

      order.update!(total:)
      order
    end
  end

  def next_status = NEXT_STATUS[status]

  def delivery_promise = DELIVERY_OPTIONS[delivery_option]

  def instant? = delivery_option == "instant"

  def open? = status.in?(%w[ placed packed ])

  # Quantities are clamped to what is on the shelf today; anything sold out drops off.
  def to_cart
    order_items.each_with_object({}) do |item, cart|
      available = [ item.quantity, item.product.stock ].min
      cart[item.product_id.to_s] = available if available.positive?
    end
  end

  def address_lines
    [ recipient_name, line1, line2, landmark, "#{city}, #{state} #{pincode}", "Phone: #{phone_number}" ].compact_blank
  end

  def address = address_lines.join(", ")
end
