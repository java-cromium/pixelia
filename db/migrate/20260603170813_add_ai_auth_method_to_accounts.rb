class AddAiAuthMethodToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :ai_auth_method, :string
    add_column :accounts, :google_ai_access_token, :text
  end
end
