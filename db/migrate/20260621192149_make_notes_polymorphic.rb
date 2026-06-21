class MakeNotesPolymorphic < ActiveRecord::Migration[8.1]
  def up
    add_column :notes, :notable_type, :string
    add_column :notes, :notable_id, :bigint

    # Migrate existing lead_id data to polymorphic
    execute <<-SQL
      UPDATE notes
      SET notable_type = 'Lead', notable_id = lead_id
      WHERE lead_id IS NOT NULL
    SQL

    remove_foreign_key :notes, :leads
    remove_column :notes, :lead_id

    change_column_null :notes, :notable_type, false
    change_column_null :notes, :notable_id, false

    add_index :notes, [:notable_type, :notable_id]
  end

  def down
    add_reference :notes, :lead, foreign_key: true

    execute <<-SQL
      UPDATE notes
      SET lead_id = notable_id
      WHERE notable_type = 'Lead'
    SQL

    remove_index :notes, [:notable_type, :notable_id]
    remove_column :notes, :notable_type
    remove_column :notes, :notable_id
  end
end
