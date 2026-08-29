class AddDeliveryOptionToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :delivery_option, :string, null: false, default: "instant"
  end
end
