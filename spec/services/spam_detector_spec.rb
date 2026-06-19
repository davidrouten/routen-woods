require "rails_helper"

RSpec.describe SpamDetector do
  describe "#score!" do
    it "marks leads with honeypot as spam" do
      lead = create(:lead, :spam)
      expect(lead.reload.spam).to be true
      expect(lead.spam_score).to be >= 0.7
    end

    it "flags fast submissions" do
      lead = create(:lead, form_completion_seconds: 1.0)
      expect(lead.reload.spam_score).to be > 0
    end

    it "flags suspicious email patterns" do
      lead = create(:lead, email: "abc123456@spam.com")
      expect(lead.reload.spam_score).to be > 0
    end

    it "flags spam words in message" do
      lead = create(:lead, message: "Free viagra and bitcoin lottery winner")
      expect(lead.reload.spam_score).to be > 0
    end

    it "scores clean leads below threshold" do
      lead = create(:lead, honeypot_value: nil, form_completion_seconds: 30)
      expect(lead.reload.spam).to be false
    end

    it "caps score at 1.0" do
      lead = create(:lead, honeypot_value: "bot", form_completion_seconds: 0.5,
                    email: "12345678@x.com", message: "free viagra bitcoin lottery")
      expect(lead.reload.spam_score).to be <= 1.0
    end
  end
end
