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

    def current_sort
      @current_sort ||= SortParam.new(params[:sort])
    end
    helper_method :current_sort
  end
end
