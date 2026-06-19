class StatusChange < ApplicationRecord
  belongs_to :lead
  belongs_to :user, optional: true

  validates :to_status, presence: true

  scope :chronological, -> { order(created_at: :asc) }
end
