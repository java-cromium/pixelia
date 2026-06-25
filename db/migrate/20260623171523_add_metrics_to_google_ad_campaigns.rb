class AddMetricsToGoogleAdCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :google_ad_campaigns, :impressions, :integer
    add_column :google_ad_campaigns, :clicks, :integer
    add_column :google_ad_campaigns, :cost_micros, :integer
    add_column :google_ad_campaigns, :conversions, :integer
    add_column :google_ad_campaigns, :metrics_synced_at, :datetime
  end
end
