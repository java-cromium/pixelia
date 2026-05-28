class CreateGoogleAdAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :google_ad_accounts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :google_customer_id
      t.string :google_email
      t.text :access_token
      t.text :refresh_token
      t.datetime :token_expires_at
      t.string :status, default: "connected", null: false

      t.timestamps
    end

    remove_index :google_ad_accounts, :account_id
    add_index :google_ad_accounts, :account_id, unique: true
    add_index :google_ad_accounts, :google_customer_id
  end
end
