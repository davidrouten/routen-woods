class PagesController < ApplicationController
  def home
    @testimonials = Testimonial.featured.positioned.limit(6)
    @gallery_images = GalleryImage.featured.positioned.limit(8)
    @lead = Lead.new
  end

  def about
  end

  def gallery
    @images = GalleryImage.positioned
  end

  def contact
    @lead = Lead.new
  end
end
