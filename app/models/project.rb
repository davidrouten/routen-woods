class Project < ApplicationRecord
  include Searchable

  searchable :title, context: "Title"
  searchable :description, context: ->(r, snip, _) { "Description: #{snip.call(r.description)}" }
  searchable :email, :phone,
             context: ->(r, _, query) { "Contact: #{r.email&.downcase&.include?(query.downcase) ? r.email : r.phone}" }
  searchable :address, context: ->(r, _, _) { "Address: #{r.address}" }
  searchable_notes!

  def search_title
    title
  end

  def search_url
    "/admin/projects/#{id}"
  end

  enum :status, {
    scheduled: 0,
    in_progress: 1,
    blocked: 2,
    complete: 3,
    paid: 4
  }

  belongs_to :lead, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :customer, optional: true
  has_many :order_forms, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  has_secure_token :client_token

  CALENDAR_COLORS = {
    "Blue"        => "#3B82F6",
    "Red"         => "#EF4444",
    "Emerald"     => "#10B981",
    "Orange"      => "#F97316",
    "Purple"      => "#8B5CF6",
    "Cyan"        => "#06B6D4",
    "Pink"        => "#EC4899",
    "Amber"       => "#F59E0B",
    "Navy"        => "#1E3A5F",
    "Lime"        => "#84CC16",
    "Crimson"     => "#B91C1C",
    "Teal"        => "#0D9488",
    "Gold"        => "#CA8A04",
    "Indigo"      => "#4338CA",
    "Charcoal"    => "#374151",
    "Coral"       => "#F87171",
    "Forest"      => "#166534",
    "Brown"       => "#78350F",
    "Silver"      => "#9CA3AF",
    "Slate"       => "#64748B",
  }.freeze

  CALENDAR_PALETTE = CALENDAR_COLORS.values.freeze

  validates :title, presence: true
  validates :calendar_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  before_create :assign_calendar_color, unless: -> { calendar_color.present? }

  scope :active, -> { where(status: [:scheduled, :in_progress, :blocked]) }
  scope :recent, -> { order(created_at: :desc) }

  def schedule
    Schedule.new(
      start_date: scheduled_start_date,
      duration_days: estimated_duration_days,
      work_saturdays: work_saturdays?
    )
  end

  def start!
    update!(status: :in_progress, started_at: Time.current)
  end

  def block!(reason = nil)
    update!(status: :blocked)
    notes.create!(body: "Blocked: #{reason}", note_type: "system", user: assigned_to) if reason.present? && assigned_to
  end

  def unblock!
    update!(status: :in_progress)
  end

  def complete!
    update!(status: :complete, completed_at: Time.current)
  end

  def mark_paid!
    update!(status: :paid, paid_at: Time.current)
  end

  def total_with_tax(invoice)
    invoice&.total || agreed_price || estimated_price
  end

  def deposit_remaining?
    deposit_amount.present? && deposit_amount > 0
  end

  def balance_remaining
    (agreed_price || 0) - (deposit_amount || 0)
  end

  private

  def assign_calendar_color
    used = Project.where.not(calendar_color: [nil, ""]).distinct.pluck(:calendar_color)
    available = CALENDAR_PALETTE - used
    self.calendar_color = available.any? ? available.first : CALENDAR_PALETTE[Project.count % CALENDAR_PALETTE.length]
  end
end
