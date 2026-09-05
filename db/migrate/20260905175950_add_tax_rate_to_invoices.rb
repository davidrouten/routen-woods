class AddTaxRateToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :tax_rate, :decimal, precision: 7, scale: 4, default: 0
  end
end
