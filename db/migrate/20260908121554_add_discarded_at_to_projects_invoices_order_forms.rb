class AddDiscardedAtToProjectsInvoicesOrderForms < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :discarded_at, :datetime
    add_column :invoices, :discarded_at, :datetime
    add_column :order_forms, :discarded_at, :datetime

    add_index :projects, :discarded_at
    add_index :invoices, :discarded_at
    add_index :order_forms, :discarded_at
  end
end
