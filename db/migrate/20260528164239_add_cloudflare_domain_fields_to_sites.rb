class AddCloudflareDomainFieldsToSites < ActiveRecord::Migration[8.0]
  def change
    add_column :sites, :cf_hostname_id, :string
    add_column :sites, :domain_status, :string, default: nil
    add_column :sites, :ssl_status, :string, default: nil
    add_column :sites, :domain_verification_token, :string
    add_column :sites, :domain_verification_errors, :jsonb, default: []

    add_index :sites, :cf_hostname_id, unique: true
    add_index :sites, :domain_status
  end
end
