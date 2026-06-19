module SalesEngines
  class BaseAdapter
    def create_lead(params) = raise(NotImplementedError)
    def update_status(lead, new_status, user: nil) = raise(NotImplementedError)
    def add_note(lead, body, user:) = raise(NotImplementedError)
    def list_leads(filters: {}) = raise(NotImplementedError)
    def search(query) = raise(NotImplementedError)
  end
end
