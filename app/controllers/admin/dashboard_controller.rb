module Admin
  class DashboardController < BaseController
    def index
      @leads_by_status = Lead.not_spam.group(:status).count
      @recent_leads = Lead.not_spam.recent.limit(10)
      @hot_leads = Lead.not_spam.hot.recent.limit(5)
      @spam_count = Lead.spam_only.count
      @leads_today = Lead.not_spam.where("created_at >= ?", Date.current.beginning_of_day).count
    end
  end
end
