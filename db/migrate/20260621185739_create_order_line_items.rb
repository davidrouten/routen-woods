class CreateOrderLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_line_items do |t|
      t.references :order_form, null: false, foreign_key: true

      # Item details
      t.string :name, null: false
      t.string :category
      t.string :color
      t.string :finish
      t.string :material
      t.string :size
      t.integer :quantity, default: 1, null: false
      t.integer :position, default: 0

      # Dimensions (nullable — not all items need them)
      t.string :width
      t.string :height
      t.string :depth

      # Financials
      t.decimal :supplier_cost, precision: 10, scale: 2
      t.decimal :our_price, precision: 10, scale: 2
      t.decimal :markup_pct, precision: 5, scale: 2

      # Catch-all for item-specific details (e.g. "hinge: XL", "style: shaker")
      t.text :specifications
      t.text :notes

      t.timestamps
    end
  end
end
