class InboundLead < ApplicationRecord
  belongs_to :lead, optional: true

  validates :source, presence: true
  validates :payload, presence: true
  validates :external_id, uniqueness: { scope: :source }, allow_nil: true

  scope :pending, -> { where(status: "pending") }
  scope :processed, -> { where(status: "processed") }
  scope :failed, -> { where(status: "failed") }
  scope :by_source, ->(s) { where(source: s) }

  def processed?
    status == "processed"
  end

  def mark_processed!(lead)
    update!(status: "processed", lead: lead, processed_at: Time.current)
  end

  def mark_failed!
    update!(status: "failed")
  end
end
