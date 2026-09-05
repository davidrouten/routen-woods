class SchedulePresenter
  PALETTE = %w[#3B82F6 #10B981 #F59E0B #8B5CF6 #EC4899 #06B6D4 #F97316 #6366F1 #14B8A6 #EF4444].freeze

  attr_reader :scheduled_projects, :unscheduled_projects

  def initialize(url_helper:)
    @url_helper = url_helper

    all_active = Project.active.includes(:customer, :lead)
    @scheduled_projects = all_active.where.not(scheduled_start_date: nil).where.not(estimated_duration_days: nil)
    @unscheduled_projects = all_active.where(scheduled_start_date: nil).or(all_active.where(estimated_duration_days: nil))
  end

  def serialize_all
    scheduled_projects.map { |p| serialize_project(p) }
  end

  def serialize_unscheduled
    unscheduled_projects.map { |p| { id: p.id, title: p.title, customer_name: customer_name(p), url: project_url(p) } }
  end

  def week_schedule(week_start, week_end)
    (week_start..week_end).map do |day|
      busy = day.sunday? ? false : scheduled_projects.any? { |p| p.schedule.work_days.include?(day) }
      { date: day, busy: busy, sunday: day.sunday? }
    end
  end

  def density_grid(start_date, weeks: 8)
    (0...weeks).map do |week_idx|
      ws = start_date + (week_idx * 7).days
      (0...7).map do |day_idx|
        day = ws + day_idx.days
        if day.sunday?
          { date: day, count: 0, sunday: true, month: day.month, project_ids: [] }
        else
          on_day = scheduled_projects.select { |p| p.schedule.work_days.include?(day) }
          { date: day, count: on_day.size, sunday: false, month: day.month, project_ids: on_day.map(&:id) }
        end
      end
    end
  end

  def key_entries(range_start, range_end)
    in_range = scheduled_projects.select { |p| p.schedule.end_date && p.schedule.end_date >= range_start && p.scheduled_start_date <= range_end }
    in_range.map { |p| key_entry(p) }
  end

  def weekly_bars(start_date, weeks: 8)
    (0...weeks).map do |week_idx|
      ws = start_date + (week_idx * 7).days
      we = ws + 6.days

      bars = scheduled_projects.filter_map do |p|
        sched = p.schedule
        next unless sched.end_date && sched.end_date >= ws && p.scheduled_start_date <= we

        work_in_week = sched.work_days.select { |d| d >= ws && d <= we }
        next if work_in_week.empty?

        start_col = (work_in_week.min - ws).to_i
        end_col = (work_in_week.max - ws).to_i
        { id: p.id, color: color_for(p), start_col: start_col, end_col: end_col, url: project_url(p), title: p.title }
      end

      days = (ws..we).map { |d| { date: d, sunday: d.sunday?, month: d.month } }
      { week_start: ws, days: days, bars: bars }
    end
  end

  def customer_name(project)
    first = project.customer&.first_name || project.lead&.first_name
    last = project.customer&.last_name || project.lead&.last_name
    return nil if first.blank?
    last.present? ? "#{first} #{last[0]}." : first
  end

  def color_for(project)
    PALETTE[project.id % PALETTE.length]
  end

  private

  def serialize_project(project)
    schedule = project.schedule
    {
      id: project.id,
      title: project.title,
      customer_name: customer_name(project),
      start_date: project.scheduled_start_date.iso8601,
      end_date: schedule.end_date&.iso8601,
      work_days: schedule.work_days.map(&:iso8601),
      status: project.status,
      work_saturdays: project.work_saturdays?,
      url: project_url(project)
    }
  end

  def key_entry(project)
    customer = customer_name(project)
    label = customer ? "#{project.title.truncate(25)} (#{customer})" : project.title.truncate(30)
    { id: project.id, label: label, color: color_for(project), url: project_url(project) }
  end

  def project_url(project)
    @url_helper.admin_project_path(project)
  end
end
