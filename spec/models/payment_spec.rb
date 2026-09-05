require "rails_helper"

RSpec.describe Payment do
  describe "validations" do
    it "requires amount" do
      payment = build(:payment, amount: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:amount]).to be_present
    end

    it "requires amount greater than 0" do
      payment = build(:payment, amount: 0)
      expect(payment).not_to be_valid
    end

    it "requires paid_at" do
      payment = build(:payment, paid_at: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:paid_at]).to be_present
    end

    it "is valid with required attributes" do
      payment = build(:payment)
      expect(payment).to be_valid
    end
  end

  describe "auto status updates" do
    it "sets invoice to partially_paid when payment leaves a balance" do
      invoice = create(:invoice, :with_items)
      create(:payment, invoice: invoice, amount: 2000)

      expect(invoice.reload).to be_partially_paid
    end

    it "sets invoice to paid when payments cover the total" do
      invoice = create(:invoice, :with_items)
      create(:payment, invoice: invoice, amount: 7000)

      expect(invoice.reload).to be_paid
    end

    it "reverts to partially_paid when a payment is destroyed and balance remains" do
      invoice = create(:invoice, :with_items)
      p1 = create(:payment, invoice: invoice, amount: 4000)
      create(:payment, invoice: invoice, amount: 3000)
      expect(invoice.reload).to be_paid

      p1.destroy!
      expect(invoice.reload).to be_partially_paid
    end
  end
end
