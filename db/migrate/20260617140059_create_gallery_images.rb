class CreateGalleryImages < ActiveRecord::Migration[8.1]
  def change
    create_table :gallery_images do |t|
      t.string :title
      t.text :description
      t.string :category
      t.string :service_category
      t.integer :position
      t.boolean :featured

      t.timestamps
    end
  end
end
