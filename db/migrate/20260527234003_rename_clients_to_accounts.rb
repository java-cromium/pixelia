class RenameClientsToAccounts < ActiveRecord::Migration[8.0]
  def change
    # Rename the table
    rename_table :clients, :accounts

    # Rename all foreign key columns
    rename_column :users, :client_id, :account_id
    rename_column :projects, :client_id, :account_id
    rename_column :ecommerce_stores, :client_id, :account_id
    rename_column :sites, :client_id, :account_id

    # Add billing & subscription fields to accounts
    add_column :accounts, :stripe_customer_id, :string
    add_column :accounts, :plan, :string, default: "free", null: false
    add_column :accounts, :subscription_status, :string, default: "trialing", null: false
    add_column :accounts, :trial_ends_at, :datetime

    add_index :accounts, :stripe_customer_id, unique: true
    add_index :accounts, :plan

    # Add new user fields
    add_column :users, :onboarding_completed_at, :datetime
  end
end
