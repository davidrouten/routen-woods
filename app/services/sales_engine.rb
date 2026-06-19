class SalesEngine
  class << self
    def adapter
      @adapter ||= SalesEngines::InternalAdapter.new
    end

    def adapter=(klass_or_instance)
      @adapter = klass_or_instance.is_a?(Class) ? klass_or_instance.new : klass_or_instance
    end

    delegate :create_lead, :update_status, :add_note, :list_leads, :search, to: :adapter
  end
end
