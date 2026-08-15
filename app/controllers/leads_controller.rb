class LeadsController < ApplicationController
  def create
    turnstile_passed = TurnstileVerifier.verify(
      params["cf-turnstile-response"],
      ip: request.remote_ip
    )

    @lead = SalesEngine.create_lead(lead_params.merge(turnstile_passed: turnstile_passed))

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, notice: t("business.forms.contact.success") }
    end
  rescue ActiveRecord::RecordInvalid => e
    @lead = e.record
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("lead_form", partial: "shared/quote_form", locals: { lead: @lead }) }
      format.html { render "pages/contact", status: :unprocessable_entity }
    end
  end

  def quote
    create
  end

  private

  def lead_params
    params.require(:lead).permit(
      :first_name, :last_name, :email, :phone,
      :budget_range, :timeframe, :zip_code, :message,
      :other_service, :lead_source,
      :address_street, :address_street2, :address_city, :address_state, :address_zip,
      :honeypot_value, :form_completion_seconds,
      services_interested_in: []
    ).merge(
      source: "website",
      ip_address: request.remote_ip,
      landing_page: request.referer,
      referrer: request.referer
    )
  end
end
