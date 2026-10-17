module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_access!
    include LegacyIdRedirect
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

    # ORDER BY nodes for SQL expressions in the current sort direction, so the
    # direction is never interpolated into the SQL string.
    def sort_order(*expressions)
      expressions.map do |sql|
        node = Arel.sql(sql)
        current_sort.desc? ? node.desc : node.asc
      end
    end
  end
end
