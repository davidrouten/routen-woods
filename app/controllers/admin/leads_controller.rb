module Admin
  class LeadsController < BaseController
    before_action :set_lead, only: [:show, :transition, :mark_spam, :unmark_spam, :assign]
    before_action -> { require_permission!(:view, :leads) }, only: [:index, :show]
    before_action -> { require_permission!(:manage, :leads) }, only: [:transition, :mark_spam, :unmark_spam, :assign]

    def index
      scope = params[:spam] == "true" ? Lead.spam_only : Lead.not_spam
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.where(lead_temperature: params[:temperature]) if params[:temperature].present?
      scope = SalesEngine.search(params[:q]) if params[:q].present?
      @pagy, @leads = pagy(:offset, scope.recent, limit: 25)
    end

    def show
      @notes = @lead.notes.reverse_chronological
      @status_changes = @lead.status_changes.chronological
      @note = Note.new
    end

    def transition
      SalesEngine.update_status(@lead, params[:status], user: current_user)
      redirect_to admin_lead_path(@lead), notice: "Status updated to #{params[:status]}."
    end

    def mark_spam
      @lead.update!(spam: true)
      redirect_to admin_leads_path, notice: "Marked as spam."
    end

    def unmark_spam
      @lead.update!(spam: false, spam_score: 0)
      redirect_to admin_lead_path(@lead), notice: "Removed from spam."
    end

    def assign
      @lead.update!(assigned_to_id: params[:user_id])
      redirect_to admin_lead_path(@lead), notice: "Lead assigned."
    end

    private

    def set_lead
      @lead = Lead.find(params[:id])
    end
  end
end
