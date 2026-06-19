class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :service_interested_in
      t.text :message
      t.string :source
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content
      t.string :landing_page
      t.string :referrer
      t.integer :status, default: 0, null: false
      t.float :spam_score, default: 0.0
      t.boolean :spam, default: false
      t.string :lead_temperature
      t.float :ai_score, default: 0.0
      t.string :ip_address
      t.float :form_completion_seconds
      t.string :honeypot_value
      t.datetime :contacted_at
      t.datetime :scheduled_at
      t.datetime :quoted_at
      t.datetime :booked_at
      t.datetime :completed_at
      t.datetime :lost_at
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :leads, :status
    add_index :leads, :spam
    add_index :leads, :lead_temperature
    add_index :leads, :created_at
    add_index :leads, [:utm_source, :utm_medium, :utm_campaign], name: "index_leads_on_utm"
  end
end
