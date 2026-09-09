class SwapLeadSourceColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :leads, :source, :lead_external_source
    rename_column :leads, :lead_source, :source
    rename_column :leads, :lead_source_reference, :lead_external_source_id
  end
end
