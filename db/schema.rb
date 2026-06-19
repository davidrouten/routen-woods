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

ActiveRecord::Schema[8.1].define(version: 2026_06_17_140059) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "gallery_images", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured"
    t.integer "position"
    t.string "service_category"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "leads", force: :cascade do |t|
    t.float "ai_score", default: 0.0
    t.bigint "assigned_to_id"
    t.datetime "booked_at"
    t.datetime "completed_at"
    t.datetime "contacted_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.float "form_completion_seconds"
    t.string "honeypot_value"
    t.string "ip_address"
    t.string "landing_page"
    t.string "last_name"
    t.string "lead_temperature"
    t.datetime "lost_at"
    t.text "message"
    t.string "phone"
    t.datetime "quoted_at"
    t.string "referrer"
    t.datetime "scheduled_at"
    t.string "service_interested_in"
    t.string "source"
    t.boolean "spam", default: false
    t.float "spam_score", default: 0.0
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.index ["assigned_to_id"], name: "index_leads_on_assigned_to_id"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["lead_temperature"], name: "index_leads_on_lead_temperature"
    t.index ["spam"], name: "index_leads_on_spam"
    t.index ["status"], name: "index_leads_on_status"
    t.index ["utm_source", "utm_medium", "utm_campaign"], name: "index_leads_on_utm"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "lead_id", null: false
    t.string "note_type", default: "manual"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["lead_id"], name: "index_notes_on_lead_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.boolean "email_enabled", default: true
    t.string "event_name", null: false
    t.boolean "slack_enabled", default: true
    t.boolean "sms_enabled", default: false
    t.datetime "updated_at", null: false
    t.index ["event_name"], name: "index_notification_preferences_on_event_name", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "resource", null: false
    t.datetime "updated_at", null: false
    t.index ["resource", "action"], name: "index_permissions_on_resource_and_action", unique: true
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

  add_foreign_key "leads", "users", column: "assigned_to_id"
  add_foreign_key "notes", "leads"
  add_foreign_key "notes", "users"
  add_foreign_key "status_changes", "leads"
  add_foreign_key "status_changes", "users"
  add_foreign_key "user_permissions", "permissions"
  add_foreign_key "user_permissions", "users"
end
