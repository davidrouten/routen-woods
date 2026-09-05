require "rails_helper"

RSpec.describe InvoiceAdjustment do
  describe "validations" do
    it "requires a label" do
      adj = build(:invoice_adjustment, label: nil)
      expect(adj).not_to be_valid
    end

    it "requires an adjustment_type" do
      adj = build(:invoice_adjustment, adjustment_type: nil)
      expect(adj).not_to be_valid
    end

    it "only allows fee or discount" do
      adj = build(:invoice_adjustment, adjustment_type: "bogus")
      expect(adj).not_to be_valid
    end

    it "does not allow tax type (tax is computed from invoice rate)" do
      adj = build(:invoice_adjustment, adjustment_type: "tax")
      expect(adj).not_to be_valid
    end

    it "requires an amount" do
      adj = build(:invoice_adjustment, amount: nil)
      expect(adj).not_to be_valid
    end

    it "allows negative amount for discounts" do
      adj = build(:invoice_adjustment, adjustment_type: "discount", amount: -200.0)
      expect(adj).to be_valid
    end
  end
end
