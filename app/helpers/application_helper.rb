module ApplicationHelper
  def business(key)
    I18n.t("business.#{key}")
  end

  def service_options_for_select
    services = I18n.t("business.services")
    services.map { |key, service| [service[:name], key.to_s] }
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
end
