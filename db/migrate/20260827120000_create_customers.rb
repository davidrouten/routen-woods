class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_table :customers do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :address_street
      t.string :address_street2
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.text :notes
      t.timestamps
    end

    add_index :customers, :email
    add_index :customers, :phone
    add_index :customers, :last_name
    add_index :customers, :email, using: :gin, opclass: :gin_trgm_ops, name: "idx_customers_email_trgm"
    add_index :customers, :phone, using: :gin, opclass: :gin_trgm_ops, name: "idx_customers_phone_trgm"
  end
end
