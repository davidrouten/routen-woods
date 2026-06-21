module Admin
  class OrderFormsController < BaseController
    before_action :set_project, except: [:index]
    before_action :set_order_form, only: [:show, :edit, :update, :destroy, :submit_order, :confirm_order, :receive_order]
    before_action -> { require_permission!(:manage, :leads) }

    def index
      scope = OrderForm.includes(:project, :line_items)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @order_forms = scope.order(created_at: :desc)
    end

    def show
    end

    def new
      @order_form = @project.order_forms.build
      @order_form.line_items.build
    end

    def create
      @order_form = @project.order_forms.build(order_form_params)
      if @order_form.save
        redirect_to admin_project_order_form_path(@project, @order_form), notice: "Order form created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @order_form.line_items.build if @order_form.line_items.empty?
    end

    def update
      if @order_form.update(order_form_params)
        redirect_to admin_project_order_form_path(@project, @order_form), notice: "Order form updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @order_form.destroy
      redirect_to admin_project_path(@project), notice: "Order form deleted."
    end

    def submit_order
      @order_form.submit!
      redirect_to admin_project_order_form_path(@project, @order_form), notice: "Order form submitted."
    end

    def confirm_order
      @order_form.confirm!
      redirect_to admin_project_order_form_path(@project, @order_form), notice: "Order confirmed."
    end

    def receive_order
      @order_form.mark_received!
      redirect_to admin_project_order_form_path(@project, @order_form), notice: "Order marked as received."
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_order_form
      @order_form = @project.order_forms.find(params[:id])
    end

    def order_form_params
      params.require(:order_form).permit(
        :supplier_name, :notes,
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
