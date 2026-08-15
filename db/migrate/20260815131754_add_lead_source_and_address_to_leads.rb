class AddLeadSourceAndAddressToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :lead_source, :string
    add_column :leads, :lead_source_reference, :string
    add_column :leads, :other_service, :string
    add_column :leads, :address_street, :string
    add_column :leads, :address_street2, :string
    add_column :leads, :address_city, :string
    add_column :leads, :address_state, :string
    add_column :leads, :address_zip, :string
  end
end
