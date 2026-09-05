module Admin
  class DashboardController < BaseController
    def index
      @leads_by_status = Lead.not_spam.group(:status).count
      @recent_leads = Lead.not_spam.recent.limit(10)
      @hot_leads = Lead.not_spam.hot.recent.limit(5)
      @spam_count = Lead.spam_only.count
      @leads_today = Lead.not_spam.where("created_at >= ?", Date.current.beginning_of_day).count

      @booked_leads = Lead.not_spam.where(status: :booked).includes(projects: :invoices).order(booked_at: :desc)
      @completed_leads = Lead.not_spam.where(status: :completed).includes(:projects).order(completed_at: :desc).limit(10)

      booked_project_ids = @booked_leads.flat_map { |l| l.projects.map(&:id) }
      @booked_revenue = Project.where(id: booked_project_ids).sum(:agreed_price)

      active_invoices = Invoice.where(project_id: booked_project_ids)
      @total_outstanding = active_invoices.total_outstanding

      @collected_this_month = Invoice.total_collected_since(Date.current.beginning_of_month)
    end
  end
end
