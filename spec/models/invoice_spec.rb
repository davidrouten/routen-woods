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

  describe "#record_payment!" do
    it "records a deposit payment" do
      invoice = create(:invoice, :with_items)
      invoice.record_payment!(2000, type: :deposit)

      expect(invoice.amount_paid).to eq(2000.0)
      expect(invoice.deposit_paid?).to be true
      expect(invoice).to be_partially_paid
    end

    it "marks as paid when fully paid" do
      invoice = create(:invoice, :with_items)
      invoice.record_payment!(7000, type: :balance)

      expect(invoice).to be_paid
    end
  end

  describe "#balance_due" do
    it "returns total minus amount paid" do
      invoice = create(:invoice, :with_items)
      invoice.record_payment!(2000, type: :deposit)
      expect(invoice.balance_due).to eq(5000.0)
    end
  end
end
