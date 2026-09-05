class AddCalendarColorToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :calendar_color, :string
  end
end
