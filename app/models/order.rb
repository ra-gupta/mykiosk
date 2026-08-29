class Order < ApplicationRecord
  STATUSES = %w[ placed packed out_for_delivery delivered cancelled ]

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :address, presence: true
  validates :status, inclusion: { in: STATUSES }

  after_create_commit -> { broadcast_prepend_to "incoming_orders", target: "incoming_orders" }
  after_create_commit -> { OwnerPushJob.perform_later(self) }

  # ponytail: leans on SQLite's single-writer transaction instead of row locks;
  # add `Product.lock` if this moves to Postgres/MySQL.
  def self.place!(user:, address:, cart:)
    transaction do
      order = new(user:, address:, total: 0)
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
end
