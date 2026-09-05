class AddSchedulingFieldsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :estimated_duration_days, :decimal, precision: 5, scale: 1
    add_column :projects, :work_saturdays, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE projects
          SET estimated_duration_days = (
            SELECT COUNT(*)
            FROM generate_series(scheduled_start_date, scheduled_end_date - INTERVAL '1 day', '1 day') AS d(dt)
            WHERE EXTRACT(DOW FROM d.dt) BETWEEN 1 AND 5
          )
          WHERE scheduled_start_date IS NOT NULL
            AND scheduled_end_date IS NOT NULL
        SQL
      end
    end
  end
end
