class TurnstileVerifier
  VERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify"

  def self.configured?
    ENV["TURNSTILE_SECRET_KEY"].present?
  end

  def self.verify(token, ip: nil)
    return true unless configured?
    return false if token.blank?

    response = Net::HTTP.post_form(
      URI(VERIFY_URL),
      "secret" => ENV["TURNSTILE_SECRET_KEY"],
      "response" => token,
      "remoteip" => ip
    )

    JSON.parse(response.body)["success"] == true
  rescue StandardError => e
    Rails.logger.error("Turnstile verification failed: #{e.message}")
    true # fail open — never block a lead due to our own error
  end
end
