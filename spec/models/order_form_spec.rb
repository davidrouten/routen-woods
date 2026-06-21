require "rails_helper"

RSpec.describe OrderForm do
  describe "validations" do
    it "requires a supplier_name" do
      of = build(:order_form, supplier_name: nil)
      expect(of).not_to be_valid
    end
  end

  describe "totals" do
    it "calculates totals from line items" do
      order_form = create(:order_form, :with_items)
      # 14 * 45 = 630 supplier, 14 * 65 = 910 our price
      # 8 * 30 = 240 supplier, 8 * 45 = 360 our price
      expect(order_form.total_supplier_cost).to eq(870.0)
      expect(order_form.total_our_price).to eq(1270.0)
      expect(order_form.total_profit).to eq(400.0)
    end
  end

  describe "status transitions" do
    it "#submit! marks as submitted" do
      of = create(:order_form)
      of.submit!
      expect(of).to be_submitted
      expect(of.submitted_at).to be_present
    end
  end
end
