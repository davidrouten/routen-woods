require "rails_helper"

RSpec.describe InvoiceLineItem do
  describe "validations" do
    it "requires a name" do
      item = build(:invoice_line_item, name: nil)
      expect(item).not_to be_valid
    end

    it "requires a unit_price" do
      item = build(:invoice_line_item, unit_price: nil)
      expect(item).not_to be_valid
    end

    it "requires positive quantity" do
      item = build(:invoice_line_item, quantity: 0)
      expect(item).not_to be_valid
    end
  end

  describe "total calculation" do
    it "auto-calculates total from unit_price * quantity" do
      item = build(:invoice_line_item, unit_price: 3500.00, quantity: 2)
      item.valid?
      expect(item.total).to eq(7000.0)
    end

    it "defaults quantity to 1" do
      item = build(:invoice_line_item, unit_price: 5000.00)
      item.valid?
      expect(item.total).to eq(5000.0)
    end
  end
end
