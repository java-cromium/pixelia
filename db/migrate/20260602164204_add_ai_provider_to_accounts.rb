class AddAiProviderToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :ai_provider, :string, default: nil
    add_column :accounts, :ai_api_key, :text, default: nil
  end
end
