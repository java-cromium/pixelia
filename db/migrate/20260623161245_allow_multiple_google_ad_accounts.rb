class AllowMultipleGoogleAdAccounts < ActiveRecord::Migration[8.0]
  def change
    # Remove unique constraint to allow multiple Google Ad accounts per account
    remove_index :google_ad_accounts, :account_id
    add_index :google_ad_accounts, :account_id

    # Add connection type to distinguish OAuth vs manual CID connections
    add_column :google_ad_accounts, :connection_type, :string, default: "oauth", null: false
    # Friendly name for the account (e.g. "Main account", "Client X")
    add_column :google_ad_accounts, :nickname, :string

    add_index :google_ad_accounts, [:account_id, :google_customer_id], unique: true, name: "idx_google_ad_accounts_on_account_and_customer"
  end
end
