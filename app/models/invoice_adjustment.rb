class InvoiceAdjustment < ApplicationRecord
  belongs_to :invoice

  validates :label, presence: true
  validates :adjustment_type, presence: true, inclusion: { in: %w[tax fee discount] }
  validates :amount, presence: true, numericality: true

  # Examples:
  #   label: "Sales Tax (6%)", adjustment_type: "tax", rate: 0.06, amount: 300.00
  #   label: "Permit Fee", adjustment_type: "fee", rate: nil, amount: 150.00
  #   label: "Repeat Customer Discount", adjustment_type: "discount", amount: -200.00
end
