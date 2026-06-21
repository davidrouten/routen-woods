class MakeProjectOptionalOnOrderFormsAndInvoices < ActiveRecord::Migration[8.1]
  def change
    change_column_null :order_forms, :project_id, true
    change_column_null :invoices, :project_id, true
  end
end
