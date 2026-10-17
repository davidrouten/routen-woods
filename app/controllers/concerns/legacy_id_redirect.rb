# Links created before public IDs (e.g. old notification emails) used numeric
# ids. Redirect GETs like /admin/projects/12/invoices/5 to the same page with
# public IDs. Only signed-in admins reach this (it runs after authentication).
#
# Temporary: remove once pre-public-ID links have aged out.
module LegacyIdRedirect
  extend ActiveSupport::Concern

  ROUTE_MODELS = {
    "leads" => "Lead",
    "customers" => "Customer",
    "projects" => "Project",
    "invoices" => "Invoice",
    "order_forms" => "OrderForm",
    "attachments" => "Attachment",
    "notes" => "Note",
    "gallery_images" => "GalleryImage",
    "testimonials" => "Testimonial"
  }.freeze

  included do
    before_action :redirect_legacy_ids, if: -> { request.get? }
  end

  private

  def redirect_legacy_ids
    segments = request.path.split("/")
    changed = false

    segments.each_with_index do |segment, i|
      next unless i.positive? && segment.match?(/\A\d+\z/)

      model = ROUTE_MODELS[segments[i - 1]]&.constantize
      public_id = model&.where(id: segment)&.pick(:public_id)
      next unless public_id

      segments[i] = public_id
      changed = true
    end

    return unless changed

    redirect_to [segments.join("/"), request.query_string.presence].compact.join("?")
  end
end
