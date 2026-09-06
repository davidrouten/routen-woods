# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_06_014312) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.bigint "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id", null: false
    t.index ["project_id"], name: "index_attachments_on_project_id"
    t.index ["uploaded_by_id"], name: "index_attachments_on_uploaded_by_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "address_city"
    t.string "address_state"
    t.string "address_street"
    t.string "address_street2"
    t.string "address_zip"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name"
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "idx_customers_email_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["email"], name: "index_customers_on_email"
    t.index ["last_name"], name: "index_customers_on_last_name"
    t.index ["phone"], name: "idx_customers_phone_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["phone"], name: "index_customers_on_phone"
  end

  create_table "gallery_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured"
    t.string "page_tags", default: [], array: true
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "inbound_leads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.bigint "lead_id"
    t.jsonb "payload", default: {}, null: false
    t.datetime "processed_at"
    t.string "source", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_inbound_leads_on_lead_id"
    t.index ["source", "external_id"], name: "index_inbound_leads_on_source_and_external_id", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["status"], name: "index_inbound_leads_on_status"
  end

  create_table "invoice_adjustments", force: :cascade do |t|
    t.string "adjustment_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "invoice_id", null: false
    t.string "label", null: false
    t.integer "position", default: 0
    t.decimal "rate", precision: 5, scale: 4
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_adjustments_on_invoice_id"
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "invoice_id", null: false
    t.string "line_type"
    t.string "name", null: false
    t.integer "position", default: 0
    t.integer "quantity", default: 1, null: false
    t.boolean "taxable", default: false, null: false
    t.decimal "total", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "deposit_amount", precision: 10, scale: 2
    t.date "due_date"
    t.decimal "fees_total", precision: 10, scale: 2, default: "0.0"
    t.string "invoice_number", null: false
    t.date "issued_date"
    t.text "notes"
    t.bigint "project_id"
    t.integer "status", default: 0, null: false
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_rate", precision: 7, scale: 4, default: "0.0"
    t.decimal "tax_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "total", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["project_id"], name: "index_invoices_on_project_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "address_city"
    t.string "address_state"
    t.string "address_street"
    t.string "address_street2"
    t.string "address_zip"
    t.float "ai_score", default: 0.0
    t.datetime "archived_at"
    t.bigint "assigned_to_id"
    t.datetime "booked_at"
    t.string "budget_range"
    t.datetime "completed_at"
    t.datetime "contacted_at"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.bigint "customer_id"
    t.string "email"
    t.string "first_name", null: false
    t.float "form_completion_seconds"
    t.string "form_page"
    t.string "honeypot_value"
    t.string "ip_address"
    t.string "landing_page"
    t.string "last_name"
    t.string "lead_source"
    t.string "lead_source_reference"
    t.string "lead_temperature"
    t.datetime "lost_at"
    t.text "message"
    t.string "other_service"
    t.string "phone"
    t.datetime "quoted_at"
    t.string "referrer"
    t.datetime "scheduled_at"
    t.string "services_interested_in", default: [], array: true
    t.string "source"
    t.boolean "spam", default: false
    t.float "spam_score", default: 0.0
    t.integer "status", default: 0, null: false
    t.string "timeframe"
    t.boolean "turnstile_passed"
    t.datetime "updated_at", null: false
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "zip_code"
    t.index ["assigned_to_id"], name: "index_leads_on_assigned_to_id"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["created_by_id"], name: "index_leads_on_created_by_id"
    t.index ["customer_id"], name: "index_leads_on_customer_id"
    t.index ["lead_temperature"], name: "index_leads_on_lead_temperature"
    t.index ["spam"], name: "index_leads_on_spam"
    t.index ["status"], name: "index_leads_on_status"
    t.index ["utm_source", "utm_medium", "utm_campaign"], name: "index_leads_on_utm"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "notable_id", null: false
    t.string "notable_type", null: false
    t.string "note_type", default: "manual"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "preferences", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id", unique: true
  end

  create_table "order_forms", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "project_id"
    t.datetime "received_at"
    t.integer "status", default: 0, null: false
    t.datetime "submitted_at"
    t.string "supplier_name"
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_order_forms_on_project_id"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.string "category"
    t.string "color"
    t.datetime "created_at", null: false
    t.string "depth"
    t.string "finish"
    t.string "height"
    t.decimal "markup_pct", precision: 5, scale: 2
    t.string "material"
    t.string "name", null: false
    t.text "notes"
    t.bigint "order_form_id", null: false
    t.decimal "our_price", precision: 10, scale: 2
    t.integer "position", default: 0
    t.integer "quantity", default: 1, null: false
    t.string "size"
    t.text "specifications"
    t.decimal "supplier_cost", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.string "width"
    t.index ["order_form_id"], name: "index_order_line_items_on_order_form_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.boolean "deposit", default: false, null: false
    t.bigint "invoice_id", null: false
    t.text "notes"
    t.datetime "paid_at", null: false
    t.string "payment_method"
    t.string "reference_number"
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "resource", null: false
    t.datetime "updated_at", null: false
    t.index ["resource", "action"], name: "index_permissions_on_resource_and_action", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "address"
    t.decimal "agreed_price", precision: 10, scale: 2
    t.bigint "assigned_to_id"
    t.decimal "balance_amount", precision: 10, scale: 2
    t.string "calendar_color"
    t.string "client_token", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.decimal "deposit_amount", precision: 10, scale: 2
    t.text "description"
    t.string "email"
    t.decimal "estimated_duration_days", precision: 5, scale: 1
    t.decimal "estimated_price", precision: 10, scale: 2
    t.text "internal_notes"
    t.bigint "lead_id"
    t.datetime "paid_at"
    t.string "phone"
    t.date "scheduled_end_date"
    t.date "scheduled_start_date"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.string "time_estimate"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.boolean "work_saturdays", default: false, null: false
    t.index ["assigned_to_id"], name: "index_projects_on_assigned_to_id"
    t.index ["client_token"], name: "index_projects_on_client_token", unique: true
    t.index ["customer_id"], name: "index_projects_on_customer_id"
    t.index ["lead_id"], name: "index_projects_on_lead_id"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "status_changes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "from_status"
    t.bigint "lead_id", null: false
    t.string "to_status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["lead_id"], name: "index_status_changes_on_lead_id"
    t.index ["user_id"], name: "index_status_changes_on_user_id"
  end

  create_table "testimonials", force: :cascade do |t|
    t.string "author_name", null: false
    t.string "author_title"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.integer "position", default: 0
    t.integer "rating", default: 5
    t.datetime "updated_at", null: false
  end

  create_table "user_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "permission_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["permission_id"], name: "index_user_permissions_on_permission_id"
    t.index ["user_id", "permission_id"], name: "index_user_permissions_on_user_id_and_permission_id", unique: true
    t.index ["user_id"], name: "index_user_permissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "projects"
  add_foreign_key "attachments", "users", column: "uploaded_by_id"
  add_foreign_key "inbound_leads", "leads"
  add_foreign_key "invoice_adjustments", "invoices"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "projects"
  add_foreign_key "leads", "customers"
  add_foreign_key "leads", "users", column: "assigned_to_id"
  add_foreign_key "notes", "users"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "order_forms", "projects"
  add_foreign_key "order_line_items", "order_forms"
  add_foreign_key "payments", "invoices"
  add_foreign_key "projects", "customers"
  add_foreign_key "projects", "leads"
  add_foreign_key "projects", "users", column: "assigned_to_id"
  add_foreign_key "status_changes", "leads"
  add_foreign_key "status_changes", "users"
  add_foreign_key "user_permissions", "permissions"
  add_foreign_key "user_permissions", "users"
end
