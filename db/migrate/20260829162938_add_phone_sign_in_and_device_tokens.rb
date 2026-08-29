class AddPhoneSignInAndDeviceTokens < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :email_address, true
    change_column_null :users, :password_digest, true
    add_column :users, :phone_number, :string
    add_column :users, :otp_digest, :string
    add_column :users, :otp_sent_at, :datetime
    add_index :users, :phone_number, unique: true

    create_table :device_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
