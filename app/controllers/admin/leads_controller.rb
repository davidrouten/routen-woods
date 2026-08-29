module Admin
  class LeadsController < BaseController
    include ActionView::RecordIdentifier
    before_action :set_lead, only: [:show, :edit, :update, :transition, :mark_spam, :unmark_spam, :archive, :restore, :assign]
    before_action -> { require_permission!(:view, :leads) }, only: [:index, :show]
    before_action -> { require_permission!(:manage, :leads) }, only: [:new, :create, :edit, :update, :transition, :mark_spam, :unmark_spam, :archive, :restore, :assign]

    def index
      scope = if params[:spam] == "true"
                Lead.spam_only
              elsif params[:archived] == "true"
                Lead.archived_only
              elsif params[:filter] == "all"
                Lead.not_spam.not_archived
              elsif params[:status].present?
                Lead.not_spam.not_archived.by_status(params[:status])
              else
                Lead.open_leads
              end

      scope = scope.where(lead_temperature: params[:temperature]) if params[:temperature].present?
      scope = SalesEngine.search(params[:q]) if params[:q].present?

      scope = case sort_column
              when "name" then scope.order(first_name: sort_direction, last_name: sort_direction)
              when "city" then scope.order(address_city: sort_direction)
              when "date" then scope.order(created_at: sort_direction)
              else scope.recent
              end

      @pagy, @leads = pagy(:offset, scope, limit: 25)
    end

    def show
      @notes = @lead.notes.reverse_chronological
      @status_changes = @lead.status_changes.chronological
      @note = Note.new
    end

    def new
      @lead = Lead.new
    end

    def create
      @lead = Lead.new(lead_params)
      @lead.created_by = current_user
      if @lead.save
        redirect_to admin_lead_path(@lead), notice: "Lead created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @lead.update(lead_params)
        redirect_to admin_lead_path(@lead), notice: "Lead updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def transition
      SalesEngine.update_status(@lead, params[:status], user: current_user)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@lead), partial: "admin/leads/lead_row", locals: { lead: @lead, current_view: params[:current_view]&.to_sym || :open }) }
        format.html { redirect_to admin_lead_path(@lead), notice: "Status updated to #{params[:status]}." }
      end
    end

    def mark_spam
      @lead.update!(spam: true)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@lead)) }
        format.html { redirect_to admin_leads_path, notice: "Marked as spam." }
      end
    end

    def unmark_spam
      @lead.update!(spam: false, spam_score: 0)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@lead)) }
        format.html { redirect_to admin_lead_path(@lead), notice: "Removed from spam." }
      end
    end

    def archive
      @lead.archive!
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@lead)) }
        format.html { redirect_to admin_leads_path, notice: "Lead archived." }
      end
    end

    def restore
      @lead.restore!
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@lead)) }
        format.html { redirect_to admin_leads_path(archived: true), notice: "Lead restored." }
      end
    end

    def assign
      @lead.update!(assigned_to_id: params[:user_id])
      redirect_to admin_lead_path(@lead), notice: "Lead assigned."
    end

    private

    def set_lead
      @lead = Lead.find(params[:id])
    end

    def lead_params
      params.require(:lead).permit(
        :first_name, :last_name, :email, :phone, :customer_id,
        :budget_range, :timeframe, :zip_code, :message,
        :status, :lead_source, :lead_source_reference, :other_service,
        :address_street, :address_street2, :address_city, :address_state, :address_zip,
        services_interested_in: []
      )
    end
  end
end
