class InvoiceAdjustment < ApplicationRecord
  belongs_to :invoice

  validates :label, presence: true
  validates :adjustment_type, presence: true, inclusion: { in: %w[fee discount] }
  validates :amount, presence: true, numericality: true
end
