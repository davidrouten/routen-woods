module Admin
  class AnalyticsController < BaseController
    before_action { require_permission!(:manage, :settings) }

    def index
      @period = params[:period].presence || "30d"
      range = period_range(@period)

      visits = Ahoy::Visit.where(started_at: range)
      events = Ahoy::Event.where(name: "$view", time: range)

      @total_visits = visits.count
      @unique_visitors = visits.distinct.count(:ip)
      @total_pageviews = events.count

      @visits_over_time = visits.group_by_day(:started_at, range: range).count
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

    def period_range(period)
      case period
      when "7d"  then 7.days.ago..Time.current
      when "30d" then 30.days.ago..Time.current
      when "90d" then 90.days.ago..Time.current
      else 30.days.ago..Time.current
      end
    end
  end
end
