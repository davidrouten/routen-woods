class SpamDetector
  SPAM_THRESHOLD = 0.7

  def initialize(lead)
    @lead = lead
    @signals = []
  end

  def score!
    calculate_signals
    total = @signals.sum { |s| s[:weight] }
    normalized = [total, 1.0].min

    @lead.update_columns(
      spam_score: normalized,
      spam: normalized >= SPAM_THRESHOLD
    )
    normalized
  end

  private

  def calculate_signals
    check_honeypot
    check_submission_speed
    check_email_pattern
    check_content_spam_words
    check_duplicate_submission
  end

  def check_honeypot
    @signals << { name: :honeypot, weight: 1.0 } if @lead.honeypot_value.present?
  end

  def check_submission_speed
    return unless @lead.form_completion_seconds
    @signals << { name: :too_fast, weight: 0.6 } if @lead.form_completion_seconds < 3.0
  end

  def check_email_pattern
    return unless @lead.email
    @signals << { name: :suspicious_email, weight: 0.3 } if @lead.email.match?(/\d{5,}@/)
  end

  def check_content_spam_words
    spam_words = %w[viagra cialis crypto bitcoin lottery winner free money click here]
    text = "#{@lead.message} #{@lead.first_name}".downcase
    hits = spam_words.count { |w| text.include?(w) }
    @signals << { name: :spam_words, weight: [hits * 0.3, 0.9].min } if hits > 0
  end

  def check_duplicate_submission
    dupes = Lead.where(email: @lead.email)
                .where("created_at > ?", 1.hour.ago)
                .where.not(id: @lead.id)
                .count
    @signals << { name: :duplicate, weight: 0.4 } if dupes >= 2
  end
end
