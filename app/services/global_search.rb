class GlobalSearch
  LIMIT = 10

  def initialize(query)
    @query = query.to_s.strip
  end

  def results
    return [] if @query.length < 2

    found = {}

    # Order matters: first match sets the subtitle, so highest-priority context goes first
    search_leads_by_name(found)
    search_leads_by_email(found)
    search_leads_by_phone(found)
    search_leads_by_address(found)
    search_leads_by_message(found)
    search_leads_by_notes(found)

    found.values.first(LIMIT)
  end

  private

  def pattern
    "%#{@query}%"
  end

  def search_leads_by_name(found)
    Lead.where("first_name ILIKE :q OR last_name ILIKE :q", q: pattern)
      .not_spam.recent.limit(LIMIT).each do |lead|
      add_lead(found, lead, "Name")
    end
  end

  def search_leads_by_email(found)
    Lead.where("email ILIKE :q", q: pattern)
      .not_spam.recent.limit(LIMIT).each do |lead|
      add_lead(found, lead, "Email: #{lead.email}")
    end
  end

  def search_leads_by_phone(found)
    Lead.where("phone ILIKE :q", q: pattern)
      .not_spam.recent.limit(LIMIT).each do |lead|
      add_lead(found, lead, "Phone: #{lead.phone}")
    end
  end

  def search_leads_by_address(found)
    Lead.where(
      "address_street ILIKE :q OR address_city ILIKE :q OR address_state ILIKE :q OR address_zip ILIKE :q",
      q: pattern
    ).not_spam.recent.limit(LIMIT).each do |lead|
      parts = [lead.address_street, lead.address_city, lead.address_state, lead.address_zip].compact_blank
      add_lead(found, lead, "Address: #{parts.join(', ')}")
    end
  end

  def search_leads_by_message(found)
    Lead.where("message ILIKE :q", q: pattern)
      .not_spam.recent.limit(LIMIT).each do |lead|
      add_lead(found, lead, "Message: #{snippet(lead.message)}")
    end
  end

  def search_leads_by_notes(found)
    notes = Note.joins(:user)
      .where(notable_type: "Lead")
      .where("notes.body ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q", q: pattern)
      .preload(:user)
      .order(created_at: :desc)
      .limit(LIMIT)

    lead_ids = notes.map(&:notable_id).uniq
    leads_by_id = Lead.where(id: lead_ids).not_spam.index_by(&:id)

    notes.each do |note|
      lead = leads_by_id[note.notable_id]
      next unless lead

      context = if note.body.downcase.include?(@query.downcase)
        "Note: #{snippet(note.body)}"
      else
        "Note by #{note.user.full_name}: #{snippet(note.body)}"
      end

      add_lead(found, lead, context)
    end
  end

  def add_lead(found, lead, match_context)
    if found[lead.id]
      found[lead.id][:match_contexts] << match_context unless found[lead.id][:match_contexts].include?(match_context)
    else
      found[lead.id] = {
        type: "Lead",
        title: lead.full_name_or_email,
        subtitle: match_context,
        match_contexts: [match_context],
        url: "/admin/leads/#{lead.id}",
        status: lead.status
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
