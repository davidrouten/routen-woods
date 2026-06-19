class Testimonial < ApplicationRecord
  validates :author_name, presence: true
  validates :body, presence: true
  validates :rating, inclusion: { in: 1..5 }

  scope :featured, -> { where(featured: true) }
  scope :positioned, -> { order(:position) }
end
