class CreateMetaAdAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :meta_ad_accounts do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.string :meta_business_id
      t.string :meta_ad_account_id
      t.string :meta_email
      t.text :access_token
      t.datetime :token_expires_at
      t.string :status, null: false, default: "connected"

      t.timestamps
    end

  end
end
