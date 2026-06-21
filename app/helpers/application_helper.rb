module ApplicationHelper
  def business(key)
    I18n.t("business.#{key}")
  end

  def service_options_for_select
    services = I18n.t("business.services")
    services.map { |key, service| [service[:name], key.to_s] }
  end

  def service_checkbox_options
    I18n.t("business.services").map { |key, service| [service[:name], key.to_s] }
  end

  def budget_range_options
    I18n.t("business.budget_ranges").map { |key, range| [range[:label], key.to_s] }
  end

  def timeframe_options
    I18n.t("business.timeframes").map { |key, tf| [tf[:label], key.to_s] }
  end

  def budget_range_label(key)
    return "—" if key.blank?
    I18n.t("business.budget_ranges.#{key}.label", default: key.titleize)
  end

  def timeframe_label(key)
    return "—" if key.blank?
    I18n.t("business.timeframes.#{key}.label", default: key.titleize)
  end


  def status_badge_color(status)
    {
      "incoming" => "bg-blue-100 text-blue-800",
      "contacted" => "bg-yellow-100 text-yellow-800",
      "scheduled" => "bg-purple-100 text-purple-800",
      "quoted" => "bg-indigo-100 text-indigo-800",
      "booked" => "bg-green-100 text-green-800",
      "completed" => "bg-emerald-100 text-emerald-800",
      "lost" => "bg-red-100 text-red-800"
    }[status] || "bg-gray-100 text-gray-800"
  end

  def temperature_badge_color(temp)
    {
      "hot" => "bg-red-100 text-red-700",
      "warm" => "bg-amber-100 text-amber-700",
      "cold" => "bg-blue-100 text-blue-700"
    }[temp] || "bg-gray-100 text-gray-600"
  end

  def responsive_gallery_image(image_attachment, alt:, sizes: "(max-width: 640px) 400px, 800px", eager: false, **html_opts)
    small = url_for(image_attachment.variant(resize_to_limit: [400, 400], format: :webp))
    medium = url_for(image_attachment.variant(resize_to_limit: [800, 800], format: :webp))

    opts = {
      src: medium,
      srcset: "#{small} 400w, #{medium} 800w",
      sizes: sizes,
      alt: alt,
      width: 800,
      height: 800,
      decoding: "async"
    }.merge(html_opts)

    if eager
      opts[:fetchpriority] = "high"
    else
      opts[:loading] = "lazy"
    end

    tag.img(**opts)
  end
end
