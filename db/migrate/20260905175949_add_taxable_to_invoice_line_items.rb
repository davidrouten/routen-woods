class AddTaxableToInvoiceLineItems < ActiveRecord::Migration[8.1]
  def change
    add_column :invoice_line_items, :taxable, :boolean, default: false, null: false
  end
end
