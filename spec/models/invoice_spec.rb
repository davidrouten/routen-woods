require "rails_helper"

RSpec.describe Invoice do
  describe "validations" do
    it "auto-generates invoice_number" do
      invoice = create(:invoice)
      expect(invoice.invoice_number).to match(/^INV-\d{4}$/)
    end
  end

  describe "#calculate_totals!" do
    it "sums line items and adjustments" do
      invoice = create(:invoice, :with_items)
      create(:invoice_adjustment, invoice: invoice, adjustment_type: "tax", amount: 420.00)
      invoice.calculate_totals!

      expect(invoice.subtotal).to eq(7000.0)
      expect(invoice.tax_total).to eq(420.0)
      expect(invoice.total).to eq(7420.0)
    end
  end

  describe "#amount_paid" do
    it "sums all payment amounts" do
      invoice = create(:invoice, :with_items)
      create(:payment, invoice: invoice, amount: 2000)
      create(:payment, invoice: invoice, amount: 1500)

      expect(invoice.amount_paid).to eq(3500.0)
    end

    it "returns 0 with no payments" do
      invoice = create(:invoice, :with_items)
      expect(invoice.amount_paid).to eq(0)
    end
  end

  describe "#balance_due" do
    it "returns total minus sum of payments" do
      invoice = create(:invoice, :with_items)
      create(:payment, invoice: invoice, amount: 2000)
      expect(invoice.balance_due).to eq(5000.0)
    end
  end

  describe "#deposit_paid?" do
    it "returns true when deposit payments cover the deposit amount" do
      invoice = create(:invoice, :with_items, deposit_amount: 2000)
      create(:payment, :deposit, invoice: invoice, amount: 2000)
      expect(invoice.deposit_paid?).to be true
    end

    it "returns true when multiple deposit payments cover the deposit amount" do
      invoice = create(:invoice, :with_items, deposit_amount: 500)
      create(:payment, :deposit, invoice: invoice, amount: 200)
      create(:payment, :deposit, invoice: invoice, amount: 300)
      expect(invoice.deposit_paid?).to be true
    end

    it "returns false when deposit payments are less than deposit amount" do
      invoice = create(:invoice, :with_items, deposit_amount: 500)
      create(:payment, :deposit, invoice: invoice, amount: 200)
      expect(invoice.deposit_paid?).to be false
    end

    it "returns false with no deposit payments" do
      invoice = create(:invoice, :with_items, deposit_amount: 2000)
      create(:payment, invoice: invoice, amount: 2000)
      expect(invoice.deposit_paid?).to be false
    end

    it "returns false when no deposit amount is set" do
      invoice = create(:invoice, :with_items, deposit_amount: nil)
      create(:payment, :deposit, invoice: invoice, amount: 500)
      expect(invoice.deposit_paid?).to be false
    end
  end

  describe "#fully_paid?" do
    it "returns true when payments cover the total" do
      invoice = create(:invoice, :with_items)
      create(:payment, invoice: invoice, amount: 7000)
      expect(invoice.fully_paid?).to be true
    end

    it "returns false with a remaining balance" do
      invoice = create(:invoice, :with_items)
      create(:payment, invoice: invoice, amount: 2000)
      expect(invoice.fully_paid?).to be false
    end
  end
end
