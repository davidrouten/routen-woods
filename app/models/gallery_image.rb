class GalleryImage < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true

  # Tag constants
  TAG_GALLERY                  = "gallery"
  TAG_HOME                     = "home"
  TAG_ABOUT                    = "about"
  TAG_CABINET_REFACING         = "cabinet_refacing"
  TAG_CABINET_REPAINTING       = "cabinet_repainting"
  TAG_CABINET_INSTALLATION     = "cabinet_installation"
  TAG_CABINET_CUSTOMIZE_REPAIR = "cabinet_customize_repair"
  TAG_CUSTOM_CLOSETS           = "custom_closets"
  TAG_COUNTERTOPS              = "countertops"

  PAGE_TAGS = {
    TAG_GALLERY                  => "Gallery",
    TAG_HOME                     => "Home Page",
    TAG_ABOUT                    => "About Us",
    TAG_CABINET_REFACING         => "Cabinet Refacing",
    TAG_CABINET_REPAINTING       => "Cabinet Repainting",
    TAG_CABINET_INSTALLATION     => "Cabinet Installation",
    TAG_CABINET_CUSTOMIZE_REPAIR => "Customization, Repair & Accessories",
    TAG_CUSTOM_CLOSETS           => "Custom Closets & Pantries",
    TAG_COUNTERTOPS              => "Countertops"
  }.freeze

  scope :featured, -> { where(featured: true) }
  scope :positioned, -> { order(Arel.sql("position IS NULL, position ASC")) }
  scope :tagged, ->(tag) { where("? = ANY(page_tags)", tag) }
end
