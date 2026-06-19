class CreateStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :status_changes do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status

      t.timestamps
    end
  end
end
