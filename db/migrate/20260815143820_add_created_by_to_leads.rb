class AddCreatedByToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :created_by_id, :bigint
    add_index :leads, :created_by_id
  end
end
