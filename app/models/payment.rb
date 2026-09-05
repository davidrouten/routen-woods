class Payment < ApplicationRecord
  belongs_to :invoice

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_at, presence: true

  after_save { invoice.update_payment_status! }
  after_destroy { invoice.update_payment_status! }
end
