class AddCustomerIdToLeadsAndProjects < ActiveRecord::Migration[8.1]
  def change
    add_reference :leads, :customer, foreign_key: true, null: true, index: true
    add_reference :projects, :customer, foreign_key: true, null: true, index: true
  end
end
