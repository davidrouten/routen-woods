class RenameNotesToInternalNotesOnProjects < ActiveRecord::Migration[8.1]
  def change
    rename_column :projects, :notes, :internal_notes
  end
end
