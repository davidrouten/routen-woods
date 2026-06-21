module Admin
  class InvoicesController < BaseController
    before_action :set_project, if: -> { params[:project_id].present? }
    before_action :set_invoice, only: [:show, :edit, :update, :destroy, :send_invoice, :record_payment]
    before_action -> { require_permission!(:manage, :leads) }

    def index
      scope = Invoice.includes(:project, :line_items)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @invoices = scope.order(created_at: :desc)
    end

    def show
    end

    def new
      @invoice = Invoice.new(
        project: @project,
        issued_date: Date.current,
        due_date: Date.current + 30.days,
        deposit_amount: @project&.deposit_amount
      )
      @invoice.line_items.build
    end

    def create
      @invoice = Invoice.new(invoice_params)
      @invoice.project = @project if @project && @invoice.project_id.blank?
      if @invoice.save
        @invoice.calculate_totals!
        redirect_to invoice_path_for(@invoice), notice: "Invoice created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @invoice.line_items.build if @invoice.line_items.empty?
    end

    def update
      if @invoice.update(invoice_params)
        @invoice.calculate_totals!
        redirect_to invoice_path_for(@invoice), notice: "Invoice updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @invoice.destroy
      if @invoice.project
        redirect_to admin_project_path(@invoice.project), notice: "Invoice deleted."
      else
        redirect_to admin_invoices_path, notice: "Invoice deleted."
      end
    end

    def send_invoice
      @invoice.update!(status: :sent)
      redirect_to invoice_path_for(@invoice), notice: "Invoice marked as sent."
    end

    def record_payment
      amount = params[:amount].to_d
      type = params[:payment_type]&.to_sym || :balance
      @invoice.record_payment!(amount, type: type)
      redirect_to invoice_path_for(@invoice), notice: "Payment recorded."
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_invoice
      @invoice = if @project
        @project.invoices.find(params[:id])
      else
        Invoice.find(params[:id])
      end
    end

    def invoice_path_for(invoice)
      if invoice.project
        admin_project_invoice_path(invoice.project, invoice)
      else
        admin_invoice_path(invoice)
      end
    end

    def invoice_params
      params.require(:invoice).permit(
        :issued_date, :due_date, :deposit_amount, :notes, :project_id,
        line_items_attributes: [:id, :name, :description, :quantity, :unit_price, :line_type, :position, :_destroy],
        adjustments_attributes: [:id, :label, :adjustment_type, :rate, :amount, :position, :_destroy]
      )
    end
  end
end
