class OrderLineItem < ApplicationRecord
  belongs_to :order_form

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  # Common categories: door_front, side_panel, drawer_front, pull, handle,
  # toe_guard, crown_moulding, countertop, paint, laminate, hinge, etc.

  def total_supplier_cost
    (supplier_cost || 0) * quantity
  end

  def total_our_price
    (our_price || 0) * quantity
  end

  def profit
    total_our_price - total_supplier_cost
  end

  def calculated_our_price
    return supplier_cost unless markup_pct.present? && supplier_cost.present?
    supplier_cost * (1 + markup_pct / 100.0)
  end
end
