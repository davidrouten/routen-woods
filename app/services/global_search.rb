class GlobalSearch
  LIMIT = 10

  # Order matters: first model's results appear first in the dropdown
  MODELS = [Lead, Project, Invoice, Customer].freeze

  def initialize(query)
    @query = query.to_s.strip
  end

  def results
    return [] if @query.length < 2

    MODELS.flat_map { |model| search_model(model) }.first(LIMIT)
  end

  private

  def pattern
    "%#{@query}%"
  end

  def search_model(model)
    found = {}

    # Order matters: first match sets the subtitle, so highest-priority context goes first
    model._search_fields.each do |defn|
      conditions = defn[:columns].map { |c| "#{c} ILIKE :q" }.join(" OR ")
      model.search_scope.where(conditions, q: pattern).limit(LIMIT).each do |record|
        context = resolve_context(defn[:context], record)
        add_result(found, record, context)
      end
    end

    search_by_notes(model, found) if model._search_includes_notes

    found.values
  end

  def resolve_context(context, record)
    case context
    when String then context
    when Proc then context.call(record, method(:snippet), @query)
    end
  end

  def search_by_notes(model, found)
    notes = Note.joins(:user)
      .where(notable_type: model.name)
      .where("notes.body ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q", q: pattern)
      .preload(:user)
      .order(created_at: :desc)
      .limit(LIMIT)

    notable_ids = notes.map(&:notable_id).uniq
    records = model.search_scope.where(id: notable_ids).index_by(&:id)

    notes.each do |note|
      record = records[note.notable_id]
      next unless record

      context = if note.body.downcase.include?(@query.downcase)
        "Note: #{snippet(note.body)}"
      else
        "Note by #{note.user.full_name}: #{snippet(note.body)}"
      end

      add_result(found, record, context)
    end
  end

  def add_result(found, record, context)
    if found[record.id]
      found[record.id][:match_contexts] << context unless found[record.id][:match_contexts].include?(context)
    else
      found[record.id] = {
        type: record.search_type,
        title: record.search_title,
        subtitle: context,
        match_contexts: [context],
        url: record.search_url,
        status: record.respond_to?(:status) ? record.status : nil
      }
    end
  end

  def snippet(text, length: 60)
    return "" if text.blank?

    idx = text.downcase.index(@query.downcase)
    return text.truncate(length) unless idx

    start = [idx - 15, 0].max
    excerpt = text[start, length]
    excerpt = "...#{excerpt}" if start > 0
    excerpt = "#{excerpt}..." if start + length < text.length
    excerpt.gsub(/\s+/, " ")
  end
end
