class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name
      t.string :project_type
      t.string :status
      t.date :launch_date

      t.timestamps
    end
  end
end
