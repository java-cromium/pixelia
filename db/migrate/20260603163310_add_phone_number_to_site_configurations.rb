class AddPhoneNumberToSiteConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_column :site_configurations, :phone_number, :string
  end
end
