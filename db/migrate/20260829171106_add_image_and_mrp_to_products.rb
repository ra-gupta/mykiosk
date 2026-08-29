class AddImageAndMrpToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :image, :string
    add_column :products, :mrp, :decimal, precision: 8, scale: 2
  end
end
