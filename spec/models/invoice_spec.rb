require "rails_helper"

RSpec.describe Invoice do
  describe "validations" do
    it "auto-generates invoice_number" do
      invoice = create(:invoice)
      expect(invoice.invoice_number).to match(/^INV-\d{4}$/)
    end
  end

  describe "#calculate_totals!" do
    it "sums line items into subtotal" do
      invoice = create(:invoice, :with_items)
      expect(invoice.subtotal).to eq(7000.0)
    end

    it "computes sales tax from tax_rate * taxable line items" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      create(:invoice_line_item, invoice: invoice, name: "Labor", unit_price: 2000.00, taxable: false)
      invoice.calculate_totals!

      expect(invoice.tax_total).to eq(300.0)
      expect(invoice.subtotal).to eq(7000.0)
      expect(invoice.total).to eq(7300.0)
    end

    it "includes fees in total" do
      invoice = create(:invoice, :with_items)
      create(:invoice_adjustment, invoice: invoice, adjustment_type: "fee", amount: 150.00)
      invoice.calculate_totals!

      expect(invoice.fees_total).to eq(150.0)
      expect(invoice.total).to eq(7150.0)
    end

    it "includes both sales tax and fees in total" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      create(:invoice_adjustment, invoice: invoice, adjustment_type: "fee", amount: 150.00)
      invoice.calculate_totals!

      expect(invoice.subtotal).to eq(5000.0)
      expect(invoice.tax_total).to eq(300.0)
      expect(invoice.fees_total).to eq(150.0)
      expect(invoice.total).to eq(5450.0)
    end

    it "returns zero tax when no line items are taxable" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Labor", unit_price: 5000.00, taxable: false)
      invoice.calculate_totals!

      expect(invoice.tax_total).to eq(0)
      expect(invoice.total).to eq(5000.0)
    end

    it "returns zero tax when tax_rate is zero" do
      invoice = create(:invoice, tax_rate: 0)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      invoice.calculate_totals!

      expect(invoice.tax_total).to eq(0)
    end

    it "subtracts discounts from total" do
      invoice = create(:invoice)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00)
      create(:invoice_adjustment, invoice: invoice, adjustment_type: "discount", label: "10% off", amount: 500.00)
      invoice.calculate_totals!

      expect(invoice.total).to eq(4500.0)
    end

    it "combines fees, tax, and discounts correctly" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      create(:invoice_adjustment, invoice: invoice, adjustment_type: "fee", label: "Permit", amount: 150.00)
      create(:invoice_adjustment, invoice: invoice, adjustment_type: "discount", label: "Loyalty", amount: 200.00)
      invoice.calculate_totals!

      expect(invoice.subtotal).to eq(5000.0)
      expect(invoice.tax_total).to eq(300.0)
      expect(invoice.fees_total).to eq(150.0)
      expect(invoice.total).to eq(5250.0)
    end
  end

  describe "#balance_due with sales tax" do
    it "includes sales tax in balance due" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      invoice.calculate_totals!

      expect(invoice.balance_due).to eq(5300.0)
    end

    it "reflects payments against tax-inclusive total" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      invoice.calculate_totals!
      create(:payment, invoice: invoice, amount: 2000)

      expect(invoice.balance_due).to eq(3300.0)
    end
  end

  describe "#fully_paid? with sales tax" do
    it "requires payment to cover tax-inclusive total" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      invoice.calculate_totals!
      create(:payment, invoice: invoice, amount: 5000)

      expect(invoice.fully_paid?).to be false
    end

    it "is true when payment covers tax-inclusive total" do
      invoice = create(:invoice, tax_rate: 0.06)
      create(:invoice_line_item, invoice: invoice, name: "Materials", unit_price: 5000.00, taxable: true)
      invoice.calculate_totals!
      create(:payment, invoice: invoice, amount: 5300)

      expect(invoice.fully_paid?).to be true
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
