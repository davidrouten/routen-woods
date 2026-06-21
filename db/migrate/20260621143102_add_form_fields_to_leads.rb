class AddFormFieldsToLeads < ActiveRecord::Migration[8.1]
  def up
    add_column :leads, :budget_range, :string
    add_column :leads, :timeframe, :string
    add_column :leads, :services_interested_in, :string, array: true, default: []
    add_column :leads, :zip_code, :string

    # Migrate existing data from singular to array
    execute <<-SQL
      UPDATE leads
      SET services_interested_in = ARRAY[service_interested_in]
      WHERE service_interested_in IS NOT NULL AND service_interested_in != ''
    SQL

    remove_column :leads, :service_interested_in
  end

  def down
    add_column :leads, :service_interested_in, :string

    execute <<-SQL
      UPDATE leads
      SET service_interested_in = services_interested_in[1]
      WHERE array_length(services_interested_in, 1) > 0
    SQL

    remove_column :leads, :services_interested_in
    remove_column :leads, :zip_code
    remove_column :leads, :timeframe
    remove_column :leads, :budget_range
  end
end
