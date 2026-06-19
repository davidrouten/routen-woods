class Permission < ApplicationRecord
  RESOURCES = %w[leads notes testimonials gallery settings users dashboard].freeze
  ACTIONS = %w[view create edit delete manage].freeze

  has_many :user_permissions, dependent: :destroy
  has_many :users, through: :user_permissions

  validates :resource, presence: true, inclusion: { in: RESOURCES }
  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :action, uniqueness: { scope: :resource }

  def to_s
    "#{action}:#{resource}"
  end
end
