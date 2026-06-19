class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  include Pagy::Method

  helper_method :current_user_can?

  private

  def current_user_can?(action, resource)
    current_user&.can?(action, resource)
  end
end
