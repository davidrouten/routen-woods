require "rails_helper"

RSpec.describe "Admin jobs dashboard", type: :request do
  it "redirects guests to sign in" do
    get "/admin/jobs"

    expect(response).to redirect_to("/users/sign_in")
  end

  it "is not available to non-admin users" do
    sign_in create(:user)

    get "/admin/jobs"

    expect(response).to have_http_status(:not_found)
  end

  it "is available to admins" do
    sign_in create(:user, :admin)

    get "/admin/jobs"
    follow_redirect! while response.redirect?

    expect(response).to have_http_status(:ok)
  end
end
