# Converts every app table's integer primary key to a UUID v7 and re-links all
# references to it (foreign keys, polymorphic columns, Ahoy user ids).
#
# - Existing rows get a v7 UUID built from their own created_at, so ordering by
#   id stays oldest -> newest. New rows get v7 ids from ApplicationRecord
#   (SecureRandom.uuid_v7); gen_random_uuid() is only the raw-SQL fallback.
# - Tables that appear in URLs keep the old integer as legacy_id, so old links
#   (e.g. sent notification emails) can redirect. Drop it after a few months.
# - Runs in one transaction: any orphaned reference aborts the whole thing.
# - Irreversible: roll back by restoring the pre-migration backup.
class ConvertPrimaryKeysToUuidV7 < ActiveRecord::Migration[8.1]
  TABLES = %w[
    users customers leads projects invoices invoice_line_items invoice_adjustments
    payments order_forms order_line_items attachments notes status_changes
    inbound_leads gallery_images testimonials notification_preferences
    permissions user_permissions active_storage_variant_records
  ].freeze

  # Tables whose ids appear in admin URLs: keep the old integer for redirects
  LEGACY_ID_TABLES = %w[
    leads customers projects invoices order_forms attachments notes gallery_images testimonials
  ].freeze

  # [table, column, referenced table, nullable orphans allowed?]
  REFERENCES = [
    ["attachments", "uploaded_by_id", "users"],
    ["inbound_leads", "lead_id", "leads"],
    ["invoice_adjustments", "invoice_id", "invoices"],
    ["invoice_line_items", "invoice_id", "invoices"],
    ["invoices", "project_id", "projects"],
    ["leads", "assigned_to_id", "users"],
    ["leads", "created_by_id", "users"],
    ["leads", "customer_id", "customers"],
    ["notes", "user_id", "users"],
    ["notification_preferences", "user_id", "users"],
    ["order_forms", "project_id", "projects"],
    ["order_line_items", "order_form_id", "order_forms"],
    ["payments", "invoice_id", "invoices"],
    ["projects", "assigned_to_id", "users"],
    ["projects", "customer_id", "customers"],
    ["projects", "lead_id", "leads"],
    ["status_changes", "lead_id", "leads"],
    ["status_changes", "user_id", "users"],
    ["user_permissions", "permission_id", "permissions"],
    ["user_permissions", "user_id", "users"],
    # Ahoy analytics: a deleted user just becomes an anonymous visit
    ["ahoy_events", "user_id", "users", true],
    ["ahoy_visits", "user_id", "users", true]
  ].freeze

  # [table, type column, id column]
  POLYMORPHIC = [
    ["active_storage_attachments", "record_type", "record_id"],
    ["attachments", "attachable_type", "attachable_id"],
    ["notes", "notable_type", "notable_id"]
  ].freeze

  def up
    create_v7_function

    # 1. A new v7 id on every table, from each row's created_at
    TABLES.each do |table|
      add_column table, :new_id, :uuid
      timestamp = column_exists?(table, :created_at) ? "created_at" : "clock_timestamp()"
      execute "UPDATE #{table} SET new_id = uuid_v7_at(#{timestamp})"
    end

    # 2. Fill new reference columns from the referenced table's new id
    REFERENCES.each do |table, column, target, orphans_ok|
      add_column table, "new_#{column}", :uuid
      execute <<~SQL
        UPDATE #{table} SET new_#{column} = #{target}.new_id
        FROM #{target} WHERE #{table}.#{column} = #{target}.id
      SQL
      assert_no_orphans(table, column) unless orphans_ok
    end

    POLYMORPHIC.each do |table, type_column, id_column|
      add_column table, "new_#{id_column}", :uuid
      select_values("SELECT DISTINCT #{type_column} FROM #{table}").each do |type|
        target = type.constantize.table_name
        raise "#{table}.#{type_column} = #{type}: #{target} is not being converted" unless TABLES.include?(target)

        execute <<~SQL
          UPDATE #{table} SET new_#{id_column} = #{target}.new_id
          FROM #{target}
          WHERE #{table}.#{type_column} = #{quote(type)} AND #{table}.#{id_column} = #{target}.id
        SQL
      end
      assert_no_orphans(table, id_column)
    end

    # 3. Drop foreign keys that touch converted tables (re-added at the end)
    saved_foreign_keys = (TABLES + REFERENCES.map(&:first)).uniq.flat_map { |t| foreign_keys(t) }.select do |fk|
      TABLES.include?(fk.to_table) || TABLES.include?(fk.from_table) && fk.column != "blob_id"
    end.uniq { |fk| fk.options[:name] }
    saved_foreign_keys.each { |fk| remove_foreign_key fk.from_table, name: fk.options[:name] }

    # 4. Swap each reference column, recreating any index that included it
    (REFERENCES.map { |t, c| [t, c] } + POLYMORPHIC.map { |t, _, c| [t, c] }).each do |table, column|
      swap_column(table, column, "new_#{column}")
    end

    # 5. Swap primary keys
    TABLES.each do |table|
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey"
      if LEGACY_ID_TABLES.include?(table)
        rename_column table, :id, :legacy_id
        change_column_default table, :legacy_id, nil
        change_column_null table, :legacy_id, true # new rows have no legacy id
        add_index table, :legacy_id, unique: true
      else
        remove_column table, :id
      end
      rename_column table, :new_id, :id
      change_column_null table, :id, false
      change_column_default table, :id, -> { "gen_random_uuid()" }
      execute "ALTER TABLE #{table} ADD PRIMARY KEY (id)"
    end

    # 6. Restore foreign keys, now on uuid columns
    saved_foreign_keys.each do |fk|
      add_foreign_key fk.from_table, fk.to_table, **fk.options.slice(:column, :primary_key, :name, :on_delete, :on_update)
    end

    execute "DROP FUNCTION uuid_v7_at(timestamptz)"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Restore the pre-migration database backup instead"
  end

  private

  # Temporary helper: a UUID v7 for a given timestamp (48-bit ms time + random bits)
  def create_v7_function
    execute <<~SQL
      CREATE FUNCTION uuid_v7_at(ts timestamptz) RETURNS uuid LANGUAGE sql VOLATILE AS $$
        SELECT encode(
          set_bit(set_bit(
            overlay(uuid_send(gen_random_uuid())
                    PLACING substring(int8send((extract(epoch FROM ts) * 1000)::bigint) FROM 3)
                    FROM 1 FOR 6),
          52, 1), 53, 1),
        'hex')::uuid
      $$
    SQL
  end

  def assert_no_orphans(table, column)
    orphans = select_value("SELECT count(*) FROM #{table} WHERE #{column} IS NOT NULL AND new_#{column} IS NULL").to_i
    raise "#{orphans} #{table}.#{column} value(s) point at missing rows; fix them before migrating" if orphans.positive?
  end

  def swap_column(table, old_column, new_column)
    not_null = !columns(table).find { |c| c.name == old_column }.null
    saved_indexes = indexes(table).select { |i| Array(i.columns).include?(old_column) }

    remove_column table, old_column # drops the indexes above too
    rename_column table, new_column, old_column
    change_column_null table, old_column, false if not_null

    saved_indexes.each do |index|
      add_index table, index.columns, name: index.name, unique: index.unique, where: index.where,
                                      using: index.using, opclass: index.opclasses, order: index.orders
    end
  end

  def quote(value)
    connection.quote(value)
  end
end
