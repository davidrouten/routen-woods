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
  has_many :payments, dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :adjustments, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :payments, allow_destroy: true, reject_if: :all_blank

  validates :invoice_number, presence: true, uniqueness: true

  def self.total_outstanding
    sum(:total) - Payment.where(invoice_id: select(:id)).sum(:amount)
  end

  def self.total_collected_since(date)
    Payment.where(invoice_id: select(:id)).where("paid_at >= ?", date).sum(:amount)
  end

  before_validation :generate_invoice_number, on: :create, if: -> { invoice_number.blank? }

  def taxable_subtotal
    line_items.select(&:taxable?).sum(&:total)
  end

  def calculated_tax
    (taxable_subtotal * (tax_rate || 0)).round(2)
  end

  def discount_total
    adjustments.where(adjustment_type: "discount").sum(:amount)
  end

  def calculate_totals!
    line_items.reload
    adjustments.reload
    self.subtotal = line_items.sum(&:total)
    self.tax_total = calculated_tax
    self.fees_total = adjustments.where(adjustment_type: "fee").sum(:amount)
    self.total = subtotal + tax_total + fees_total - discount_total
    save!
  end

  def amount_paid
    payments.sum(:amount)
  end

  def balance_due
    total - amount_paid
  end

  def deposit_paid?
    deposit_amount.present? && deposit_amount > 0 && payments.where(deposit: true).sum(:amount) >= deposit_amount
  end

  def fully_paid?
    amount_paid >= total && total > 0
  end

  def update_payment_status!
    if payments.any? && balance_due <= 0
      mark_as_paid!
    elsif payments.any?
      mark_as_partially_paid!
    end
  end

  def mark_as_paid!
    update!(status: :paid) unless paid?
  end

  def mark_as_partially_paid!
    update!(status: :partially_paid) unless partially_paid?
  end

  private

  def generate_invoice_number
    last = Invoice.order(created_at: :desc).pick(:invoice_number)
    num = last ? last.scan(/\d+/).last.to_i + 1 : 1001
    self.invoice_number = "INV-#{num.to_s.rjust(4, '0')}"
  end
end
