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
  has_many :order_forms, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  has_secure_token :client_token

  validates :title, presence: true

  scope :active, -> { where(status: [:scheduled, :in_progress, :blocked]) }
  scope :recent, -> { order(created_at: :desc) }

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
end
