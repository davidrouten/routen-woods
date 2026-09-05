class Schedule
  attr_reader :start_date, :duration_days, :work_saturdays

  def initialize(start_date:, duration_days:, work_saturdays: false)
    @start_date = start_date
    @duration_days = duration_days&.to_d
    @work_saturdays = work_saturdays
  end

  def scheduled?
    start_date.present? && duration_days&.positive?
  end

  def end_date
    return nil unless scheduled?

    current = start_date
    if duration_days == duration_days.floor
      (duration_days.to_i - 1).times { current = next_work_day(current) }
    else
      duration_days.floor.to_i.times { current = next_work_day(current) }
    end
    current
  end

  def work_days
    return [] unless scheduled?

    days = [start_date]
    current = start_date
    (duration_days.ceil.to_i - 1).times do
      current = next_work_day(current)
      days << current
    end
    days
  end

  def formatted
    return nil unless start_date

    result = start_date.strftime("%a, %b %-d")
    if scheduled? && end_date != start_date
      result += " - #{end_date.strftime('%a, %b %-d')}"
    end
    result += " (#{formatted_duration})" if formatted_duration
    result
  end

  def formatted_duration
    return nil unless duration_days&.positive?

    if duration_days == duration_days.floor
      "#{duration_days.to_i} #{'day'.pluralize(duration_days.to_i)}"
    else
      "#{duration_days.to_f} days"
    end
  end

  private

  def next_work_day(date)
    date += 1.day
    date += 1.day while skip_day?(date)
    date
  end

  def skip_day?(date)
    return true if date.sunday?
    return true if date.saturday? && !work_saturdays
    false
  end
end
