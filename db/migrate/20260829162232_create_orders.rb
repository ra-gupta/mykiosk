class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "placed"
      t.text :address, null: false
      t.decimal :total, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
