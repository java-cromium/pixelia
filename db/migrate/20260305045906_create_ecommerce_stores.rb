class CreateEcommerceStores < ActiveRecord::Migration[8.0]
  def change
    create_table :ecommerce_stores do |t|
      t.references :project, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :platform
      t.string :store_url
      t.string :api_key
      t.string :api_secret

      t.timestamps
    end
  end
end
