class Attachment < ApplicationRecord
  belongs_to :project
  belongs_to :uploaded_by, class_name: "User"

  has_one_attached :file, service: (Rails.env.production? ? :amazon_private : nil)

  validates :file, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def filename
    file.filename.to_s
  end

  def image?
    file.content_type&.start_with?("image/")
  end

  def file_size
    file.byte_size
  end
end
