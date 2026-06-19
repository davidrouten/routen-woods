require "rails_helper"

RSpec.describe TurnstileVerifier do
  describe ".configured?" do
    it "returns false when TURNSTILE_SECRET_KEY is not set" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TURNSTILE_SECRET_KEY").and_return(nil)
      expect(TurnstileVerifier.configured?).to be false
    end

    it "returns true when TURNSTILE_SECRET_KEY is set" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TURNSTILE_SECRET_KEY").and_return("test-secret")
      allow(ENV).to receive(:fetch).and_call_original
      expect(TurnstileVerifier.configured?).to be true
    end
  end

  describe ".verify" do
    context "when not configured" do
      before do
        allow(TurnstileVerifier).to receive(:configured?).and_return(false)
      end

      it "returns true (allow all)" do
        expect(TurnstileVerifier.verify(nil)).to be true
      end
    end

    context "when configured" do
      before do
        allow(TurnstileVerifier).to receive(:configured?).and_return(true)
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("TURNSTILE_SECRET_KEY").and_return("test-secret")
      end

      it "returns false for blank token" do
        expect(TurnstileVerifier.verify("")).to be false
      end

      it "returns true on successful verification" do
        stub_request(:post, TurnstileVerifier::VERIFY_URL)
          .to_return(body: { success: true }.to_json)

        expect(TurnstileVerifier.verify("valid-token")).to be true
      end

      it "returns false on failed verification" do
        stub_request(:post, TurnstileVerifier::VERIFY_URL)
          .to_return(body: { success: false }.to_json)

        expect(TurnstileVerifier.verify("invalid-token")).to be false
      end

      it "fails open on network error" do
        stub_request(:post, TurnstileVerifier::VERIFY_URL)
          .to_raise(StandardError.new("network error"))

        expect(TurnstileVerifier.verify("some-token")).to be true
      end
    end
  end
end
