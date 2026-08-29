class ReplaceOrderAddressWithFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :address, :text, null: false
    change_table :orders, bulk: true do |t|
      t.string :recipient_name, null: false
      t.string :phone_number, null: false
      t.string :pincode, null: false
      t.string :line1, null: false
      t.string :line2, null: false
      t.string :landmark
      t.string :city, null: false
      t.string :state, null: false
    end
  end
end
