module Admin
  class AnalyticsController < BaseController
    before_action { require_permission!(:manage, :settings) }

    def index
      @month = parse_month(params[:month])
      @earliest_month = Ahoy::Visit.minimum(:started_at)&.to_date&.beginning_of_month || @month
      @month = @earliest_month if @month < @earliest_month
      @prev_month = @month.prev_month
      @next_month = @month.next_month
      @is_current_month = @month.year == Date.current.year && @month.month == Date.current.month
      @is_earliest_month = @month.year == @earliest_month.year && @month.month == @earliest_month.month

      range = @month.beginning_of_month.beginning_of_day..@month.end_of_month.end_of_day

      visits = Ahoy::Visit.where(started_at: range)
        .where("landing_page IS NULL OR landing_page NOT LIKE ?", "%/admin%")
      events = Ahoy::Event.where(name: "$view", time: range)
        .where("properties->>'page' IS NULL OR properties->>'page' NOT LIKE ?", "/admin%")

      @total_visits = visits.count
      @unique_visitors = visits.distinct.count(:ip)
      @total_pageviews = events.count

      @visits_over_time = visits.group_by_day(:started_at, range: range).count
      @unique_visitors_over_time = visits.group_by_day(:started_at, range: range).count("DISTINCT ip")
      @pageviews_over_time = events.group_by_day(:time, range: range).count

      @top_pages = events
        .where("properties->>'page' IS NOT NULL")
        .group("properties->>'page'")
        .order(Arel.sql("count(*) DESC"))
        .limit(10)
        .count

      @browsers = visits.where.not(browser: [nil, ""])
        .group(:browser).order(Arel.sql("count(*) DESC")).limit(10).count

      @devices = visits.where.not(device_type: [nil, ""])
        .group(:device_type).order(Arel.sql("count(*) DESC")).count

      @referrers = visits.where.not(referring_domain: [nil, ""])
        .group(:referring_domain).order(Arel.sql("count(*) DESC")).limit(10).count

      @form_views = Ahoy::Event.where(name: "$view", time: range)
        .where("properties->>'page' IN (?)", ["/contact", "/"])
        .group("properties->>'page'")
        .count

      submit_events = Ahoy::Event.where(name: "form_submit", time: range)
      @form_submits = submit_events.count
      @form_submits_by_page = submit_events
        .where("properties->>'page' IS NOT NULL")
        .group("properties->>'page'")
        .order(Arel.sql("count(*) DESC"))
        .count

      image_events = Ahoy::Event.where(name: "image_view", time: range)
      @image_views_total = image_events.count
      @image_views_by_page = image_events
        .where("properties->>'page' IS NOT NULL")
        .group("properties->>'page'")
        .order(Arel.sql("count(*) DESC"))
        .count

      @top_images = image_events
        .where("properties->>'alt' IS NOT NULL AND properties->>'alt' != ''")
        .group("properties->>'alt'")
        .order(Arel.sql("count(*) DESC"))
        .limit(15)
        .count
    end

    private

    def parse_month(param)
      Date.strptime(param, "%Y-%m")
    rescue ArgumentError, TypeError
      Date.current
    end
  end
end
