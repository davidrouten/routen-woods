class AddFormPageToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :form_page, :string
  end
end
