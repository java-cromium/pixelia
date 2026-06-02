class CreateSiteConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :site_configurations do |t|
      t.references :site, null: false, foreign_key: true
      t.string :business_name
      t.string :industry
      t.string :tagline
      t.text :value_proposition
      t.jsonb :services_list
      t.text :about_content
      t.text :team_info
      t.string :video_url
      t.string :location_address
      t.decimal :location_lat
      t.decimal :location_lng
      t.string :service_area
      t.string :google_business_profile_url
      t.jsonb :faqs

      t.timestamps
    end
  end
end
