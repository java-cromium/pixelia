class CreateSites < ActiveRecord::Migration[8.0]
  def change
    create_table :sites do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name, null: false
      t.string :subdomain
      t.string :custom_domain
      t.jsonb :theme_config, default: {}
      t.boolean :published, default: false, null: false

      t.timestamps
    end

    add_index :sites, :subdomain, unique: true
    add_index :sites, :custom_domain, unique: true
  end
end
