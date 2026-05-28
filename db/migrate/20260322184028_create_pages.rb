class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.references :site, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.jsonb :content, default: {}
      t.text :html_content
      t.text :css_content
      t.string :status, default: "draft", null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :pages, [:site_id, :slug], unique: true
  end
end
