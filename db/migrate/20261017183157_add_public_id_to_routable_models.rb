# Public IDs are the only IDs that leave the server (URLs, JSON, form fields).
# Internal integer IDs and foreign keys are unchanged. Postgres generates a
# distinct UUID for every existing row when the column is added.
class AddPublicIdToRoutableModels < ActiveRecord::Migration[8.1]
  TABLES = %i[
    leads
    customers
    projects
    invoices
    order_forms
    attachments
    notes
    gallery_images
    testimonials
  ].freeze

  def change
    TABLES.each do |table|
      add_column table, :public_id, :uuid, null: false, default: -> { "gen_random_uuid()" }
      add_index table, :public_id, unique: true
    end
  end
end
