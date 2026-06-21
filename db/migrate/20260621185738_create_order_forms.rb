class CreateOrderForms < ActiveRecord::Migration[8.1]
  def change
    create_table :order_forms do |t|
      t.references :project, null: false, foreign_key: true

      t.string :supplier_name
      t.integer :status, default: 0, null: false
      t.text :notes
      t.datetime :submitted_at
      t.datetime :confirmed_at
      t.datetime :received_at

      t.timestamps
    end
  end
end
