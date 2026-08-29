class Product < ApplicationRecord
  EMOJI = {
    "tomato" => "🍅", "potato" => "🥔", "onion" => "🧅", "spinach" => "🥬", "carrot" => "🥕",
    "cauliflower" => "🥦", "broccoli" => "🥦", "chilli" => "🌶️", "coriander" => "🌿",
    "brinjal" => "🍆", "lady finger" => "🫛", "cucumber" => "🥒", "corn" => "🌽",
    "capsicum" => "🫑", "garlic" => "🧄", "mushroom" => "🍄", "peas" => "🫛", "beetroot" => "🫒",
    "banana" => "🍌", "apple" => "🍎", "mango" => "🥭", "orange" => "🍊", "grapes" => "🍇"
  }.freeze

  has_one_attached :photo
  has_many :order_items

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :mrp, numericality: { greater_than_or_equal_to: :price }, allow_nil: true

  scope :in_stock, -> { where("stock > 0") }

  def emoji = EMOJI.find { |word, _| name.downcase.include?(word) }&.last || "🥬"

  def discount_percentage
    return if mrp.blank? || mrp <= price

    (100 * (mrp - price) / mrp).round
  end
end
