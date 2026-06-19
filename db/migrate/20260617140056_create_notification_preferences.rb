class CreateNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preferences do |t|
      t.string :event_name, null: false
      t.boolean :email_enabled, default: true
      t.boolean :sms_enabled, default: false
      t.boolean :slack_enabled, default: true
      t.jsonb :config, default: {}

      t.timestamps
    end

    add_index :notification_preferences, :event_name, unique: true
  end
end
