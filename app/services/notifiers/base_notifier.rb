module Notifiers
  class BaseNotifier
    attr_reader :event_name, :lead, :context

    def initialize(event_name, lead, **context)
      @event_name = event_name
      @lead = lead
      @context = context
    end

    def deliver_later
      raise NotImplementedError
    end

    def deliver_now
      raise NotImplementedError
    end

    private

    def message_params
      {
        name: lead.first_name,
        service: lead.service_interested_in,
        status: lead.status,
        url: Rails.application.routes.url_helpers.admin_lead_url(lead, host: default_host)
      }.merge(context)
    end

    def default_host
      ENV.fetch("APP_HOST", "localhost:3000")
    end
  end
end
