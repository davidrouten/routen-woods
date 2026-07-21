class ServicesController < ApplicationController
  before_action :set_lead
  before_action :set_gallery_images

  ACTION_TAG_MAP = {
    "cabinet_refacing"         => GalleryImage::TAG_CABINET_REFACING,
    "cabinet_repainting"       => GalleryImage::TAG_CABINET_REPAINTING,
    "cabinet_installation"     => GalleryImage::TAG_CABINET_INSTALLATION,
    "cabinet_customize_repair" => GalleryImage::TAG_CABINET_CUSTOMIZE_REPAIR,
    "custom_closets"           => GalleryImage::TAG_CUSTOM_CLOSETS,
    "countertops"              => GalleryImage::TAG_COUNTERTOPS
  }.freeze

  def cabinet_refacing; end
  def cabinet_repainting; end
  def cabinet_installation; end
  def cabinet_customize_repair; end
  def custom_closets; end
  def countertops; end

  private

  def set_lead
    @lead = Lead.new
  end

  def set_gallery_images
    tag = ACTION_TAG_MAP[action_name]
    @gallery_images = GalleryImage.tagged(tag).positioned
  end
end
