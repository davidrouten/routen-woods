# For jobs that send a notification to an outside service (Slack, Twilio).
# Retries once after RETRY_WAIT and reports each step to OpsAlert:
#   first failure  -> "Couldn't send ..., retrying"
#   retry succeeds -> "Sent on retry ..."
#   retry fails    -> "Gave up ..."
# Including jobs must define #delivery_description, e.g. "SMS to John Smithers (New lead: Jane Doe)".
module DeliveryRetry
  extend ActiveSupport::Concern

  RETRY_WAIT = 2.minutes

  RETRYABLE_ERRORS = [
    Slack::Notifier::APIError,
    Twilio::REST::TwilioError,
    Net::OpenTimeout,
    Net::ReadTimeout,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    SocketError,
    OpenSSL::SSL::SSLError
  ].freeze

  included do
    retry_on(*RETRYABLE_ERRORS, wait: RETRY_WAIT, attempts: 2) do |job, error|
      OpsAlert.post("❌ Gave up: #{job.delivery_description}. Error: #{error.class}: #{error.message}")
    end

    around_perform do |job, block|
      block.call
      OpsAlert.post("✅ Sent on retry: #{job.delivery_description}") if job.executions > 1
    rescue *RETRYABLE_ERRORS => e
      if job.executions == 1
        OpsAlert.post("⚠️ Couldn't send #{job.delivery_description}. Retrying in #{RETRY_WAIT.inspect}. Error: #{e.class}: #{e.message}")
      end
      raise
    end
  end
end
