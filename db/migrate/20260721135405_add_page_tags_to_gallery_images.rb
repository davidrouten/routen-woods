class AddPageTagsToGalleryImages < ActiveRecord::Migration[8.1]
  def change
    add_column :gallery_images, :page_tags, :string, array: true, default: []
    remove_column :gallery_images, :category, :string
    remove_column :gallery_images, :service_category, :string
  end
end
