class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :first_name
      t.string :email
      t.string :project_type
      t.string :status

      t.timestamps
    end
  end
end
