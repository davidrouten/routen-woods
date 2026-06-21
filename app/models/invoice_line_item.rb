class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice

  validates :name, presence: true
  validates :unit_price, presence: true, numericality: true
  validates :quantity, numericality: { greater_than: 0 }

  before_validation :calculate_total

  # line_type: "materials", "labor", "other"

  private

  def calculate_total
    self.total = (unit_price || 0) * (quantity || 1)
  end
end
