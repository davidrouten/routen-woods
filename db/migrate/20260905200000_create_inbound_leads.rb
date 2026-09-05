class CreateInboundLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :inbound_leads do |t|
      t.string :source, null: false
      t.string :external_id
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: "pending"
      t.datetime :processed_at
      t.references :lead, foreign_key: true

      t.timestamps
    end

    add_index :inbound_leads, [:source, :external_id], unique: true, where: "external_id IS NOT NULL"
    add_index :inbound_leads, :status
  end
end
