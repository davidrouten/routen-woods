class GalleryImage < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true

  scope :featured, -> { where(featured: true) }
  scope :positioned, -> { order(:position) }
  scope :by_category, ->(cat) { where(category: cat) }
end
