class CreatePayments < ActiveRecord::Migration[8.1]
  def up
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :paid_at, null: false
      t.boolean :deposit, default: false, null: false
      t.text :notes
      t.string :payment_method
      t.string :reference_number

      t.timestamps
    end

    # Migrate existing amount_paid data into payment records
    execute <<~SQL
      INSERT INTO payments (invoice_id, amount, paid_at, deposit, created_at, updated_at)
      SELECT id, amount_paid, COALESCE(deposit_paid_at, created_at), true, NOW(), NOW()
      FROM invoices
      WHERE amount_paid > 0 AND deposit_paid_at IS NOT NULL
    SQL

    execute <<~SQL
      INSERT INTO payments (invoice_id, amount, paid_at, deposit, created_at, updated_at)
      SELECT id, amount_paid, COALESCE(balance_paid_at, created_at), false, NOW(), NOW()
      FROM invoices
      WHERE amount_paid > 0 AND deposit_paid_at IS NULL
    SQL

    remove_column :invoices, :amount_paid
    remove_column :invoices, :deposit_paid_at
    remove_column :invoices, :balance_paid_at
  end

  def down
    add_column :invoices, :amount_paid, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :invoices, :deposit_paid_at, :datetime
    add_column :invoices, :balance_paid_at, :datetime

    execute <<~SQL
      UPDATE invoices SET amount_paid = (
        SELECT COALESCE(SUM(amount), 0) FROM payments WHERE payments.invoice_id = invoices.id
      )
    SQL

    drop_table :payments
  end
end
