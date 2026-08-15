class Lead < ApplicationRecord
  enum :status, {
    incoming: 0,
    contacted: 1,
    scheduled: 2,
    quoted: 3,
    booked: 4,
    completed: 5,
    lost: 6
  }

  LEAD_SOURCES = [
    "Routenwoods.com",
    "Angi",
    "Word of Mouth",
    "Referral",
    "Google Search",
    "Next Door",
    "Facebook",
    "Other"
  ].freeze

  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  has_many :notes, as: :notable, dependent: :destroy
  has_many :status_changes, dependent: :destroy
  has_many :projects, dependent: :nullify

  validates :first_name, presence: true
  validates :email, presence: true, unless: -> { phone.present? }
  validates :phone, presence: true, unless: -> { email.present? }

  scope :not_spam, -> { where(spam: false) }
  scope :spam_only, -> { where(spam: true) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :archived_only, -> { where.not(archived_at: nil) }
  scope :open_leads, -> { not_spam.not_archived.where.not(status: [:completed, :lost]) }
  scope :by_status, ->(s) { where(status: s) }
  scope :hot, -> { where(lead_temperature: "hot") }
  scope :warm, -> { where(lead_temperature: "warm") }
  scope :cold, -> { where(lead_temperature: "cold") }
  scope :recent, -> { order(created_at: :desc) }

  def archive!
    update!(archived_at: Time.current)
  end

  def restore!
    update!(archived_at: nil)
  end

  def archived?
    archived_at.present?
  end

  after_create :calculate_spam_score
  after_create :calculate_lead_temperature
  after_create :notify_new_lead

  def transition_to!(new_status, user: nil)
    old_status = status
    update!(status: new_status)
    timestamp_col = "#{new_status}_at"
    update_column(timestamp_col, Time.current) if has_attribute?(timestamp_col)
    status_changes.create!(from_status: old_status, to_status: new_status, user: user)
    NotificationService.notify(:status_changed, self, from: old_status, to: new_status)
  end

  def full_name_or_email
    name = [first_name, last_name].compact_blank.join(" ")
    name.present? ? name : email
  end

  def service_names
    names = []
    if services_interested_in.present?
      services = I18n.t("business.services")
      names = services_interested_in.filter_map { |k| services.dig(k.to_sym, :name) }
    end
    names << "Other: #{other_service}" if other_service.present?
    names.join(", ")
  end

  def temperature_emoji
    case lead_temperature
    when "hot" then "\u{1F525}"
    when "warm" then "\u{1F324}"
    when "cold" then "\u{2744}\u{FE0F}"
    end
  end

  private

  def calculate_spam_score
    SpamDetector.new(self).score!
  end

  def calculate_lead_temperature
    LeadScorer.new(self).score!
  end

  def notify_new_lead
    return if spam?
    NotificationService.notify(:new_lead, self)
  end
end
