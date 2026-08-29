module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_access!
    layout "admin"

    private

    def authorize_access!
      unless current_user.admin? || current_user.can?(:view, :dashboard)
        redirect_to root_path, alert: "Not authorized"
      end
    end

    def require_permission!(action, resource)
      unless current_user.can?(action, resource)
        redirect_to admin_root_path, alert: "Not authorized"
      end
    end

    def sort_column
      params[:sort]&.delete_prefix("-")
    end

    def sort_desc?
      params[:sort]&.start_with?("-")
    end

    def sort_direction
      sort_desc? ? "desc" : "asc"
    end
    helper_method :sort_column, :sort_desc?, :sort_direction
  end
end
