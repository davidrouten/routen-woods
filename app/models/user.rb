class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_many :user_permissions, dependent: :destroy
  has_many :permissions, through: :user_permissions
  has_many :notes, dependent: :nullify
  has_many :assigned_leads, class_name: "Lead", foreign_key: :assigned_to_id, dependent: :nullify
  has_one :notification_preference, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  after_create :create_default_notification_preference, if: :admin?

  def full_name
    "#{first_name} #{last_name}"
  end

  def can?(action, resource)
    return true if admin?

    action = action.to_s
    resource = resource.to_s

    permissions.exists?(resource: resource, action: "manage") ||
      permissions.exists?(resource: resource, action: action)
  end

  def grant!(action, resource)
    perm = Permission.find_or_create_by!(resource: resource.to_s, action: action.to_s)
    user_permissions.find_or_create_by!(permission: perm)
  end

  def revoke!(action, resource)
    perm = Permission.find_by(resource: resource.to_s, action: action.to_s)
    user_permissions.where(permission: perm).destroy_all if perm
  end

  def grant_all!(resource)
    grant!(:manage, resource)
  end

  private

  def create_default_notification_preference
    create_notification_preference!(preferences: NotificationPreference.default_preferences)
  end
end
