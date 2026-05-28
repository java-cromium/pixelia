class CreateGoogleAdCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :google_ad_campaigns do |t|
      t.references :account, null: false, foreign_key: true
      t.references :google_ad_account, null: false, foreign_key: true
      t.string :google_campaign_id
      t.string :name
      t.string :campaign_type
      t.string :status
      t.bigint :budget_amount_micros
      t.string :target_url
      t.date :start_date
      t.date :end_date
      t.jsonb :settings
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :google_ad_campaigns, :google_campaign_id, unique: true
    add_index :google_ad_campaigns, [:account_id, :status]
  end
end
