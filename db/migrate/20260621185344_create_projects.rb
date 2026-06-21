class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :lead, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }, null: true

      # Basic info
      t.string :title, null: false
      t.text :description
      t.text :notes
      t.string :address
      t.string :email
      t.string :phone

      # Status
      t.integer :status, default: 0, null: false

      # Financial
      t.decimal :estimated_price, precision: 10, scale: 2
      t.decimal :agreed_price, precision: 10, scale: 2
      t.decimal :deposit_amount, precision: 10, scale: 2
      t.decimal :balance_amount, precision: 10, scale: 2

      # Scheduling
      t.string :time_estimate
      t.date :scheduled_start_date
      t.date :scheduled_end_date

      # Client access
      t.string :client_token, null: false

      # Timestamps for state transitions
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :paid_at

      t.timestamps
    end

    add_index :projects, :client_token, unique: true
    add_index :projects, :status
  end
end
