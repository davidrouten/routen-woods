# Fingerprints every row count and relationship covered by the UUID v7 migration,
# keyed by row timestamps (not ids), so output before and after must be identical.
#
#   bin/rails runner script/verify_uuid_migration.rb > before.txt
#   bin/rails db:migrate
#   bin/rails runner script/verify_uuid_migration.rb > after.txt && diff before.txt after.txt
require "digest"
require Rails.root.join("db/migrate/20261017191426_convert_primary_keys_to_uuid_v7.rb")
mig = ConvertPrimaryKeysToUuidV7
conn = ActiveRecord::Base.connection
identity = lambda do |table, alias_|
  cols = conn.columns(table).map(&:name)
  expr = %w[created_at time started_at].find { |c| cols.include?(c) }
  expr ? "#{alias_}.#{expr}::text" : "#{alias_}.blob_id::text || #{alias_}.variation_digest"
end
out = {}
(mig::TABLES + %w[ahoy_events ahoy_visits active_storage_attachments]).uniq.sort.each do |t|
  out["rows #{t}"] = conn.select_value("SELECT count(*) FROM #{t}").to_i
end
mig::REFERENCES.each do |table, column, target|
  sql = "SELECT count(*), md5(coalesce(string_agg(#{identity[table, 'c']} || '>' || #{identity[target, 'p']}, ',' ORDER BY #{identity[table, 'c']} || '>' || #{identity[target, 'p']}), '')) FROM #{table} c JOIN #{target} p ON c.#{column} = p.id"
  out["ref #{table}.#{column}"] = conn.select_rows(sql).first.join(" ")
end
mig::POLYMORPHIC.each do |table, type_col, id_col|
  conn.select_values("SELECT DISTINCT #{type_col} FROM #{table}").sort.each do |type|
    target = type.constantize.table_name
    sql = "SELECT count(*), md5(coalesce(string_agg(#{identity[table, 'c']} || '>' || #{identity[target, 'p']}, ',' ORDER BY #{identity[table, 'c']} || '>' || #{identity[target, 'p']}), '')) FROM #{table} c JOIN #{target} p ON c.#{id_col} = p.id WHERE c.#{type_col} = #{conn.quote(type)}"
    out["poly #{table}.#{id_col} (#{type})"] = conn.select_rows(sql).first.join(" ")
  end
end
out.each { |k, v| puts "#{k}: #{v}" }
