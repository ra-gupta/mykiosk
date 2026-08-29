class AddOwnerToUsersAndTokenToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :owner, :boolean, null: false, default: false
    add_column :sessions, :token, :string
    add_index :sessions, :token, unique: true
  end
end
