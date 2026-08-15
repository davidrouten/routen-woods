class Invoice < ApplicationRecord
  include Searchable

  searchable :invoice_number, context: "Invoice #"
  searchable :notes, context: ->(r, snip, _) { "Notes: #{snip.call(r.notes)}" }

  def search_title
    invoice_number
  end

  def search_url
    if project_id
      "/admin/projects/#{project_id}/invoices/#{id}"
    else
      "/admin/invoices/#{id}"
    end
  end

  enum :status, {
    draft: 0,
    sent: 1,
    partially_paid: 2,
    paid: 3
  }

  belongs_to :project, optional: true
  has_many :line_items, class_name: "InvoiceLineItem", dependent: :destroy
  has_many :adjustments, class_name: "InvoiceAdjustment", dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :adjustments, allow_destroy: true, reject_if: :all_blank

  validates :invoice_number, presence: true, uniqueness: true

  before_validation :generate_invoice_number, on: :create, if: -> { invoice_number.blank? }

  def calculate_totals!
    self.subtotal = line_items.sum { |li| li.total }
    self.tax_total = adjustments.where(adjustment_type: "tax").sum(:amount)
    self.fees_total = adjustments.where(adjustment_type: "fee").sum(:amount)
    self.total = subtotal + tax_total + fees_total
    save!
  end

  def balance_due
    total - amount_paid
  end

  def deposit_paid?
    deposit_paid_at.present?
  end

  def fully_paid?
    amount_paid >= total
  end

  def record_payment!(amount, type:)
    self.amount_paid += amount
    case type
    when :deposit
      self.deposit_paid_at = Time.current
      self.status = :partially_paid
    when :balance
      self.balance_paid_at = Time.current
      self.status = :paid if fully_paid?
    end
    save!
  end

  private

  def generate_invoice_number
    last = Invoice.order(created_at: :desc).pick(:invoice_number)
    num = last ? last.scan(/\d+/).last.to_i + 1 : 1001
    self.invoice_number = "INV-#{num.to_s.rjust(4, '0')}"
  end
end
