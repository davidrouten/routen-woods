module Admin
  class ScheduleController < BaseController
    before_action -> { require_permission!(:view, :leads) }

    def index
      presenter = SchedulePresenter.new(url_helper: self)
      @scheduled_projects = presenter.serialize_all
      @unscheduled_projects = presenter.serialize_unscheduled
    end
  end
end
