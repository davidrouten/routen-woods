class PagesController < ApplicationController
  def home
    @testimonials = Testimonial.featured.positioned.limit(6)
    @gallery_images = GalleryImage.tagged(GalleryImage::TAG_HOME).positioned.limit(8)
    @lead = Lead.new
  end

  def about
  end

  def gallery
    @images = GalleryImage.tagged(GalleryImage::TAG_GALLERY).positioned
  end

  def contact
    @lead = Lead.new
  end
end
