module SalesEngines
  class InternalAdapter < BaseAdapter
    def create_lead(params)
      Lead.create!(params)
    end

    def update_status(lead, new_status, user: nil)
      lead.transition_to!(new_status, user: user)
    end

    def add_note(lead, body, user:)
      lead.notes.create!(body: body, user: user)
    end

    def list_leads(filters: {})
      scope = Lead.not_spam.recent
      scope = scope.by_status(filters[:status]) if filters[:status]
      scope = scope.where(lead_temperature: filters[:temperature]) if filters[:temperature]
      scope
    end

    def search(query)
      Lead.where(
        "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR phone ILIKE :q",
        q: "%#{query}%"
      ).recent
    end
  end
end
