class CreateInvoiceLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_line_items do |t|
      t.references :invoice, null: false, foreign_key: true

      t.string :name, null: false
      t.string :description
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :line_type
      t.integer :position, default: 0

      t.timestamps
    end

    # Tax/fee line items (separate from product lines)
    create_table :invoice_adjustments do |t|
      t.references :invoice, null: false, foreign_key: true

      t.string :label, null: false
      t.string :adjustment_type, null: false
      t.decimal :rate, precision: 5, scale: 4
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
