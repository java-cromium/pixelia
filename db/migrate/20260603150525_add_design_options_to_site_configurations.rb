class AddDesignOptionsToSiteConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_column :site_configurations, :color_palette, :integer
    add_column :site_configurations, :font_combo, :integer
  end
end
