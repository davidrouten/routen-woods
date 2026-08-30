class AddUserToNotificationPreferences < ActiveRecord::Migration[8.1]
  def up
    execute "DELETE FROM notification_preferences"
    add_reference :notification_preferences, :user, null: false, foreign_key: true
    remove_index :notification_preferences, :event_name
    add_index :notification_preferences, [:user_id, :event_name], unique: true
  end

  def down
    remove_index :notification_preferences, [:user_id, :event_name]
    remove_reference :notification_preferences, :user
    add_index :notification_preferences, :event_name, unique: true
  end
end
