module Admin
  class OrderFormsController < BaseController
    before_action :set_project, if: -> { params[:project_id].present? }
    before_action :set_order_form, only: [:show, :edit, :update, :destroy, :submit_order, :confirm_order, :receive_order, :pdf]
    before_action -> { require_permission!(:manage, :leads) }

    def index
      scope = OrderForm.includes(:project, :line_items)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @order_forms = scope.order(created_at: :desc)
    end

    def show
    end

    def new
      @order_form = OrderForm.new(project: @project)
      @order_form.line_items.build
    end

    def create
      @order_form = OrderForm.new(order_form_params)
      @order_form.project = @project if @project && @order_form.project_id.blank?
      if @order_form.save
        redirect_to order_form_path_for(@order_form), notice: "Order form created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @order_form.line_items.build if @order_form.line_items.empty?
    end

    def update
      if @order_form.update(order_form_params)
        redirect_to order_form_path_for(@order_form), notice: "Order form updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @order_form.destroy
      if @order_form.project
        redirect_to admin_project_path(@order_form.project), notice: "Order form deleted."
      else
        redirect_to admin_order_forms_path, notice: "Order form deleted."
      end
    end

    def submit_order
      @order_form.submit!
      redirect_to order_form_path_for(@order_form), notice: "Order form submitted."
    end

    def confirm_order
      @order_form.confirm!
      redirect_to order_form_path_for(@order_form), notice: "Order confirmed."
    end

    def receive_order
      @order_form.mark_received!
      redirect_to order_form_path_for(@order_form), notice: "Order marked as received."
    end

    def pdf
      html = render_to_string(template: "pdfs/order_form", layout: "pdf")
      pdf_data = PdfService.render(html)
      send_data pdf_data,
        filename: "Order-#{@order_form.supplier_name.parameterize}-#{@order_form.id}.pdf",
        type: :pdf,
        disposition: params[:download] ? :attachment : :inline
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_order_form
      @order_form = if @project
        @project.order_forms.find(params[:id])
      else
        OrderForm.find(params[:id])
      end
    end

    def order_form_path_for(order_form)
      if order_form.project
        admin_project_order_form_path(order_form.project, order_form)
      else
        admin_order_form_path(order_form)
      end
    end

    def order_form_params
      params.require(:order_form).permit(
        :supplier_name, :notes, :project_id,
        line_items_attributes: [
          :id, :name, :category, :color, :finish, :material, :size,
          :quantity, :position, :width, :height, :depth,
          :supplier_cost, :our_price, :markup_pct,
          :specifications, :notes, :_destroy
        ]
      )
    end
  end
end
