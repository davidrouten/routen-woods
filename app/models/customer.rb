class Customer < ApplicationRecord
  include Searchable

  searchable :first_name, :last_name, context: "Name"
  searchable :email, context: ->(r, _, _) { "Email: #{r.email}" }
  searchable :phone, context: ->(r, _, _) { "Phone: #{r.phone}" }

  def search_title
    full_name
  end

  def search_url
    "/admin/customers/#{id}"
  end

  has_many :leads, dependent: :nullify
  has_many :projects, dependent: :nullify
  has_many :invoices, through: :projects

  validates :first_name, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def full_name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def total_revenue
    projects.sum(:agreed_price)
  end

  def total_collected
    invoices.sum(:amount_paid)
  end

  def total_outstanding
    total_revenue - total_collected
  end
end
