class MakeAttachmentsPolymorphic < ActiveRecord::Migration[8.1]
  def up
    add_column :attachments, :attachable_type, :string
    add_column :attachments, :attachable_id, :bigint

    execute <<~SQL
      UPDATE attachments SET attachable_type = 'Project', attachable_id = project_id
    SQL

    change_column_null :attachments, :attachable_type, false
    change_column_null :attachments, :attachable_id, false

    add_index :attachments, [:attachable_type, :attachable_id]

    remove_reference :attachments, :project, foreign_key: true
  end

  def down
    add_reference :attachments, :project, foreign_key: true

    execute <<~SQL
      UPDATE attachments SET project_id = attachable_id WHERE attachable_type = 'Project'
    SQL

    remove_index :attachments, [:attachable_type, :attachable_id]
    remove_column :attachments, :attachable_type
    remove_column :attachments, :attachable_id
  end
end
