require "rails_helper"

RSpec.describe OrderLineItem do
  describe "validations" do
    it "requires a name" do
      item = build(:order_line_item, name: nil)
      expect(item).not_to be_valid
    end

    it "requires positive quantity" do
      item = build(:order_line_item, quantity: 0)
      expect(item).not_to be_valid
    end
  end

  describe "#total_supplier_cost" do
    it "multiplies supplier_cost by quantity" do
      item = build(:order_line_item, supplier_cost: 45.00, quantity: 14)
      expect(item.total_supplier_cost).to eq(630.0)
    end

    it "returns 0 when supplier_cost is nil" do
      item = build(:order_line_item, supplier_cost: nil, quantity: 5)
      expect(item.total_supplier_cost).to eq(0)
    end
  end

  describe "#total_our_price" do
    it "multiplies our_price by quantity" do
      item = build(:order_line_item, our_price: 65.00, quantity: 14)
      expect(item.total_our_price).to eq(910.0)
    end
  end

  describe "#profit" do
    it "calculates profit per item * quantity" do
      item = build(:order_line_item, supplier_cost: 45.00, our_price: 65.00, quantity: 10)
      expect(item.profit).to eq(200.0)
    end
  end

  describe "#calculated_our_price" do
    it "applies markup_pct to supplier_cost" do
      item = build(:order_line_item, supplier_cost: 100.00, markup_pct: 50.0)
      expect(item.calculated_our_price).to eq(150.0)
    end

    it "returns supplier_cost when no markup" do
      item = build(:order_line_item, supplier_cost: 100.00, markup_pct: nil)
      expect(item.calculated_our_price).to eq(100.0)
    end
  end
end
