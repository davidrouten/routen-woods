module Admin
  class GalleryImagesController < BaseController
    before_action -> { require_permission!(:view, :gallery) }, only: [:index]
    before_action -> { require_permission!(:manage, :gallery) }, except: [:index]
    before_action :set_gallery_image, only: [:edit, :update, :destroy]

    def index
      @gallery_images = GalleryImage.positioned
    end

    def new
      @gallery_image = GalleryImage.new
    end

    def create
      @gallery_image = GalleryImage.new(gallery_image_params)
      if @gallery_image.save
        redirect_to admin_gallery_images_path, notice: "Image added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @gallery_image.update(gallery_image_params)
        redirect_to admin_gallery_images_path, notice: "Image updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @gallery_image.destroy
      redirect_to admin_gallery_images_path, notice: "Image deleted."
    end

    private

    def set_gallery_image
      @gallery_image = GalleryImage.find(params[:id])
    end

    def gallery_image_params
      params.require(:gallery_image).permit(:title, :description, :category, :service_category, :position, :featured, :image)
    end
  end
end
