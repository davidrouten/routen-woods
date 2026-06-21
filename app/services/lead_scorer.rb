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
    points += 10 if @lead.services_interested_in.present?

    # High-value services
    high_value = %w[cabinet_refacing cabinet_installation custom_closets]
    if @lead.services_interested_in.present?
      points += 15 if (@lead.services_interested_in & high_value).any?
    end

    # Budget scoring
    points += budget_points

    # Timeframe scoring
    points += timeframe_points

    # Engagement
    points += 10 if @lead.referrer.present?
    points += 5 if @lead.utm_source.present?

    temperature = case points
                  when 70..Float::INFINITY then "hot"
                  when 40..69 then "warm"
                  else "cold"
                  end

    @lead.update_columns(lead_temperature: temperature, ai_score: points)
  end

  private

  def budget_points
    case @lead.budget_range
    when "20k_plus" then 15
    when "15_20k" then 12
    when "10_15k" then 10
    when "5_10k" then 5
    else 0
    end
  end

  def timeframe_points
    case @lead.timeframe
    when "asap" then 20
    when "within_month" then 15
    when "1_3_months" then 10
    when "3_6_months" then 5
    else 0
    end
  end
end
