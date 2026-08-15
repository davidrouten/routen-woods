module Searchable
  extend ActiveSupport::Concern

  included do
    class_attribute :_search_fields, default: []
    class_attribute :_search_includes_notes, default: false
  end

  class_methods do
    # Declare searchable columns and how to label the match.
    #   context: "Name"                              — static label
    #   context: ->(record, snippet, query) { ... }  — dynamic label
    def searchable(*columns, context:)
      self._search_fields = _search_fields + [{ columns: columns.map(&:to_s), context: context }]
    end

    def searchable_notes!
      self._search_includes_notes = true
    end

    def search_scope
      respond_to?(:recent) ? recent : order(created_at: :desc)
    end
  end

  def search_title
    raise NotImplementedError, "#{self.class.name} must implement #search_title"
  end

  def search_url
    raise NotImplementedError, "#{self.class.name} must implement #search_url"
  end

  def search_type
    self.class.name
  end
end
