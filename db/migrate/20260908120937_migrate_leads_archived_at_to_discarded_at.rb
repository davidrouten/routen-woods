class MigrateLeadsArchivedAtToDiscardedAt < ActiveRecord::Migration[8.1]
  def change
    rename_column :leads, :archived_at, :discarded_at
  end
end
