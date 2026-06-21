module Admin
  class InvoicesController < BaseController
    before_action :set_project, except: [:index]
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
      @invoice = @project.invoices.build(
        issued_date: Date.current,
        due_date: Date.current + 30.days,
        deposit_amount: @project.deposit_amount
      )
      @invoice.line_items.build
    end

    def create
      @invoice = @project.invoices.build(invoice_params)
      if @invoice.save
        @invoice.calculate_totals!
        redirect_to admin_project_invoice_path(@project, @invoice), notice: "Invoice created."
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
        redirect_to admin_project_invoice_path(@project, @invoice), notice: "Invoice updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @invoice.destroy
      redirect_to admin_project_path(@project), notice: "Invoice deleted."
    end

    def send_invoice
      @invoice.update!(status: :sent)
      redirect_to admin_project_invoice_path(@project, @invoice), notice: "Invoice marked as sent."
    end

    def record_payment
      amount = params[:amount].to_d
      type = params[:payment_type]&.to_sym || :balance
      @invoice.record_payment!(amount, type: type)
      redirect_to admin_project_invoice_path(@project, @invoice), notice: "Payment recorded."
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_invoice
      @invoice = @project.invoices.find(params[:id])
    end

    def invoice_params
      params.require(:invoice).permit(
        :issued_date, :due_date, :deposit_amount, :notes,
        line_items_attributes: [:id, :name, :description, :quantity, :unit_price, :line_type, :position, :_destroy],
        adjustments_attributes: [:id, :label, :adjustment_type, :rate, :amount, :position, :_destroy]
      )
    end
  end
end
