class CreateAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :attachments do |t|
      t.references :project, null: false, foreign_key: true
      t.text :description
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
