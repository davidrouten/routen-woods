module Webhooks
  class AngiController < ActionController::API
    before_action :verify_api_key

    def create
      inbound = InboundLead.create!(
        source: "angi",
        external_id: payload_params[:leadOid]&.to_s,
        payload: payload_params.to_unsafe_h
      )

      Rails.logger.info("[AngiWebhook] Saved InboundLead##{inbound.id} (leadOid=#{inbound.external_id})")

      render json: { status: "success" }
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.info("[AngiWebhook] Duplicate lead ignored (leadOid=#{payload_params[:leadOid]})")
      render json: { status: "success" }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn("[AngiWebhook] Validation failed (leadOid=#{payload_params[:leadOid]}): #{e.message}")
      render json: { status: "success" }
    rescue => e
      Rails.logger.error("[AngiWebhook] Failed to save lead: #{e.message}")
      render json: { status: "error" }, status: :internal_server_error
    end

    private

    def verify_api_key
      expected = Rails.application.credentials.dig(:angi, :api_key) || ENV["ANGI_WEBHOOK_API_KEY"]

      if expected.blank?
        Rails.logger.error("[AngiWebhook] No API key configured — rejecting request")
        head :service_unavailable
        return
      end

      unless ActiveSupport::SecurityUtils.secure_compare(request.headers["x-api-key"].to_s, expected)
        head :unauthorized
      end
    end

    def payload_params
      params.permit!
    end
  end
end
