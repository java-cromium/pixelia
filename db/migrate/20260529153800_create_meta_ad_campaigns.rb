class CreateMetaAdCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :meta_ad_campaigns do |t|
      t.references :account, null: false, foreign_key: true
      t.references :meta_ad_account, null: false, foreign_key: true
      t.string :meta_campaign_id
      t.string :name, null: false
      t.string :objective, null: false, default: "OUTCOME_TRAFFIC"
      t.string :status, null: false, default: "draft"
      t.bigint :daily_budget_cents
      t.bigint :lifetime_budget_cents
      t.string :target_url
      t.date :start_date
      t.date :end_date
      t.jsonb :settings, default: {}
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :meta_ad_campaigns, :meta_campaign_id
    add_index :meta_ad_campaigns, [:account_id, :status]
  end
end
