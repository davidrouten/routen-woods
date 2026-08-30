class RedesignNotificationPreferences < ActiveRecord::Migration[8.1]
  def up
    execute "DELETE FROM notification_preferences"
    remove_index :notification_preferences, [:user_id, :event_name]
    remove_column :notification_preferences, :event_name
    remove_column :notification_preferences, :email_enabled
    remove_column :notification_preferences, :sms_enabled
    remove_column :notification_preferences, :slack_enabled
    remove_column :notification_preferences, :config
    add_column :notification_preferences, :preferences, :jsonb, null: false, default: {}
    remove_index :notification_preferences, :user_id
    add_index :notification_preferences, :user_id, unique: true
  end

  def down
    remove_index :notification_preferences, :user_id
    remove_column :notification_preferences, :preferences
    add_column :notification_preferences, :config, :jsonb, default: {}
    add_column :notification_preferences, :email_enabled, :boolean, default: true
    add_column :notification_preferences, :event_name, :string
    add_column :notification_preferences, :sms_enabled, :boolean, default: false
    add_column :notification_preferences, :slack_enabled, :boolean, default: true
    add_index :notification_preferences, [:user_id, :event_name], unique: true
  end
end
