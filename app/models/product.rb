class Product < ApplicationRecord
  has_many :order_items

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :in_stock, -> { where("stock > 0") }
end
