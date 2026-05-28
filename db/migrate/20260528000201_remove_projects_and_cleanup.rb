class RemoveProjectsAndCleanup < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :ecommerce_stores, :projects
    remove_index :ecommerce_stores, :project_id, if_exists: true
    remove_column :ecommerce_stores, :project_id, :bigint

    drop_table :projects do |t|
      t.bigint "account_id", null: false
      t.string "name"
      t.string "project_type"
      t.string "status"
      t.date "launch_date"
      t.timestamps
      t.index ["account_id"], name: "index_projects_on_account_id"
    end
  end
end
