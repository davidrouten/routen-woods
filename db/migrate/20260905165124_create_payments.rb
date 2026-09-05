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

    # Case 1: deposit only (no balance payment recorded)
    execute <<~SQL
      INSERT INTO payments (invoice_id, amount, paid_at, deposit, created_at, updated_at)
      SELECT id, amount_paid, deposit_paid_at, true, NOW(), NOW()
      FROM invoices
      WHERE amount_paid > 0
        AND deposit_paid_at IS NOT NULL
        AND balance_paid_at IS NULL
    SQL

    # Case 2: balance only (no deposit payment recorded)
    execute <<~SQL
      INSERT INTO payments (invoice_id, amount, paid_at, deposit, created_at, updated_at)
      SELECT id, amount_paid, COALESCE(balance_paid_at, created_at), false, NOW(), NOW()
      FROM invoices
      WHERE amount_paid > 0
        AND deposit_paid_at IS NULL
    SQL

    # Case 3a: both deposit and balance recorded — deposit portion uses deposit_amount
    execute <<~SQL
      INSERT INTO payments (invoice_id, amount, paid_at, deposit, created_at, updated_at)
      SELECT id,
        CASE WHEN deposit_amount IS NOT NULL AND deposit_amount > 0
          THEN deposit_amount
          ELSE amount_paid
        END,
        deposit_paid_at, true, NOW(), NOW()
      FROM invoices
      WHERE amount_paid > 0
        AND deposit_paid_at IS NOT NULL
        AND balance_paid_at IS NOT NULL
    SQL

    # Case 3b: both deposit and balance recorded — balance is the remainder
    execute <<~SQL
      INSERT INTO payments (invoice_id, amount, paid_at, deposit, created_at, updated_at)
      SELECT id,
        amount_paid - deposit_amount,
        balance_paid_at, false, NOW(), NOW()
      FROM invoices
      WHERE amount_paid > 0
        AND deposit_paid_at IS NOT NULL
        AND balance_paid_at IS NOT NULL
        AND deposit_amount IS NOT NULL
        AND deposit_amount > 0
        AND amount_paid > deposit_amount
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

    execute <<~SQL
      UPDATE invoices SET deposit_paid_at = (
        SELECT MIN(paid_at) FROM payments WHERE payments.invoice_id = invoices.id AND payments.deposit = true
      )
    SQL

    execute <<~SQL
      UPDATE invoices SET balance_paid_at = (
        SELECT MAX(paid_at) FROM payments WHERE payments.invoice_id = invoices.id AND payments.deposit = false
      )
    SQL

    drop_table :payments
  end
end
