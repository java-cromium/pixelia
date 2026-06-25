class AddProviderOAuthTokensToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :openai_access_token, :text
    add_column :accounts, :claude_access_token, :text
  end
end
