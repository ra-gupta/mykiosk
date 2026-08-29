class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.string :unit, null: false, default: "kg"
      t.integer :stock, null: false, default: 0

      t.timestamps
    end
  end
end
