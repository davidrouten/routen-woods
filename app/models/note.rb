class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true, touch: true
  belongs_to :user

  validates :body, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :reverse_chronological, -> { order(created_at: :desc) }
end
