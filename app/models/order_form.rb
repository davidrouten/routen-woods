class OrderForm < ApplicationRecord
  enum :status, {
    draft: 0,
    submitted: 1,
    confirmed: 2,
    received: 3
  }

  belongs_to :project, optional: true
  has_many :line_items, class_name: "OrderLineItem", dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :all_blank

  validates :supplier_name, presence: true

  def total_supplier_cost
    line_items.sum { |li| (li.supplier_cost || 0) * li.quantity }
  end

  def total_our_price
    line_items.sum { |li| (li.our_price || 0) * li.quantity }
  end

  def total_profit
    total_our_price - total_supplier_cost
  end

  def submit!
    update!(status: :submitted, submitted_at: Time.current)
  end

  def confirm!
    update!(status: :confirmed, confirmed_at: Time.current)
  end

  def mark_received!
    update!(status: :received, received_at: Time.current)
  end
end
