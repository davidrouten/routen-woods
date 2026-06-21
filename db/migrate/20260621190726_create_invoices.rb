class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :project, null: false, foreign_key: true

      t.string :invoice_number, null: false
      t.integer :status, default: 0, null: false
      t.date :issued_date
      t.date :due_date

      # Totals (cached for quick display)
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_total, precision: 10, scale: 2, default: 0
      t.decimal :fees_total, precision: 10, scale: 2, default: 0
      t.decimal :total, precision: 10, scale: 2, default: 0

      # Payment tracking
      t.decimal :deposit_amount, precision: 10, scale: 2
      t.decimal :amount_paid, precision: 10, scale: 2, default: 0
      t.datetime :deposit_paid_at
      t.datetime :balance_paid_at

      t.text :notes

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
  end
end
