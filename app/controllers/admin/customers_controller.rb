module Admin
  class CustomersController < BaseController
    before_action :set_customer, only: [:show, :edit, :update]
    before_action -> { require_permission!(:view, :leads) }, only: [:index, :show, :suggest]
    before_action -> { require_permission!(:manage, :leads) }, only: [:edit, :update]

    def index
      scope = Customer.left_joins(:leads, :projects)
        .select("customers.*, COUNT(DISTINCT leads.id) AS lead_count, COUNT(DISTINCT projects.id) AS project_count")
        .group("customers.id")

      if params[:q].present?
        q = "%#{params[:q]}%"
        scope = scope.where(
          "customers.first_name ILIKE :q OR customers.last_name ILIKE :q OR customers.email ILIKE :q OR customers.phone ILIKE :q",
          q: q
        )
      end

      @pagy, @customers = pagy(:offset, scope.order("customers.created_at DESC"), limit: 25)
    end

    def show
      @leads = @customer.leads.order(created_at: :desc)
      @projects = @customer.projects.includes(:invoices).order(created_at: :desc)
      @invoices = @customer.invoices.order(created_at: :desc)
    end

    def edit
    end

    def update
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: "Customer updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def suggest
      matches = CustomerMatcher.find_matches(email: params[:email], phone: params[:phone])
      render json: matches.map { |c|
        {
          id: c.id,
          name: c.full_name,
          email: c.email,
          phone: c.phone,
          lead_count: c.leads.size,
          project_count: c.projects.size
        }
      }
    end

    private

    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(
        :first_name, :last_name, :email, :phone,
        :address_street, :address_street2, :address_city, :address_state, :address_zip
      )
    end
  end
end
