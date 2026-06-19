class CreateTestimonials < ActiveRecord::Migration[8.1]
  def change
    create_table :testimonials do |t|
      t.string :author_name, null: false
      t.string :author_title
      t.text :body, null: false
      t.integer :rating, default: 5
      t.boolean :featured, default: false
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
