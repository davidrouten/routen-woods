module Admin
  class ProjectsController < BaseController
    before_action :set_project, only: [:show, :edit, :update, :destroy, :transition]
    before_action -> { require_permission!(:view, :leads) }, only: [:index, :show]
    before_action -> { require_permission!(:manage, :leads) }, only: [:new, :create, :edit, :update, :destroy, :transition]

    def index
      scope = Project.includes(:lead)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @pagy, @projects = pagy(:offset, scope.recent, limit: 25)
    end

    def show
      @order_forms = @project.order_forms.includes(:line_items)
      @invoices = @project.invoices
      @notes = @project.notes.includes(:user).reverse_chronological
    end

    def new
      @project = Project.new
      if params[:lead_id]
        @lead = Lead.find(params[:lead_id])
        @project.lead = @lead
        @project.title = "#{@lead.service_names.presence || 'Project'} — #{@lead.first_name} #{@lead.last_name}"
        @project.email = @lead.email
        @project.phone = @lead.phone
        @project.address = @lead.zip_code
        @project.description = @lead.message
        @project.customer = @lead.customer if @lead.customer
      end
    end

    def create
      @project = Project.new(project_params)

      if @project.save
        if @project.lead
          @project.lead.transition_to!(:booked, user: current_user) unless @project.lead.booked?
          if @project.customer_id.nil? && @project.lead.customer_id.present?
            @project.update_column(:customer_id, @project.lead.customer_id)
          end
        end
        redirect_to admin_project_path(@project), notice: "Project created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @project.update(project_params)
        redirect_to admin_project_path(@project), notice: "Project updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @project.destroy
      redirect_to admin_projects_path, notice: "Project deleted."
    end

    def transition
      new_status = params[:status]
      case new_status
      when "in_progress"
        @project.start!
      when "blocked"
        @project.block!(params[:reason])
      when "complete"
        @project.complete!
      when "paid"
        @project.mark_paid!
      else
        @project.update!(status: new_status)
      end
      redirect_to admin_project_path(@project), notice: "Project moved to #{new_status.titleize}."
    end

    private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(
        :lead_id, :assigned_to_id, :customer_id, :title, :description, :internal_notes,
        :address, :email, :phone,
        :estimated_price, :agreed_price, :deposit_amount, :balance_amount,
        :time_estimate, :scheduled_start_date, :scheduled_end_date
      )
    end
  end
end
