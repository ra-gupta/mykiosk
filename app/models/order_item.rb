class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  def subtotal = price * quantity
end
