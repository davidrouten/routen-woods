class LeadScorer
  def initialize(lead)
    @lead = lead
  end

  def score!
    points = 0

    # Completeness
    points += 15 if @lead.email.present?
    points += 15 if @lead.phone.present?
    points += 10 if @lead.last_name.present?
    points += 20 if @lead.message.present? && @lead.message.length > 20
    points += 10 if @lead.service_interested_in.present?

    # High-value services
    high_value = %w[cabinet_refacing cabinet_installation custom_closets]
    points += 15 if high_value.include?(@lead.service_interested_in)

    # Engagement
    points += 10 if @lead.referrer.present?
    points += 5 if @lead.utm_source.present?

    temperature = case points
                  when 70..100 then "hot"
                  when 40..69 then "warm"
                  else "cold"
                  end

    @lead.update_columns(lead_temperature: temperature, ai_score: points)
  end
end
