require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_datetime" do
    it "returns em dash for nil" do
      expect(helper.format_datetime(nil)).to eq("—")
    end

    it "formats a datetime in Eastern time" do
      dt = Time.utc(2026, 8, 15, 21, 5, 0)
      result = helper.format_datetime(dt)
      expect(result).to eq("Aug 15, 2026 @ 5:05pm")
    end

    it "handles midnight correctly" do
      dt = Time.utc(2026, 1, 1, 5, 0, 0)
      result = helper.format_datetime(dt)
      expect(result).to eq("Jan 01, 2026 @ 12:00am")
    end

    it "handles noon correctly" do
      dt = Time.utc(2026, 6, 15, 16, 0, 0)
      result = helper.format_datetime(dt)
      expect(result).to eq("Jun 15, 2026 @ 12:00pm")
    end

    it "accounts for EST vs EDT" do
      winter = Time.utc(2026, 12, 15, 17, 30, 0)
      summer = Time.utc(2026, 7, 15, 16, 30, 0)
      expect(helper.format_datetime(winter)).to eq("Dec 15, 2026 @ 12:30pm")
      expect(helper.format_datetime(summer)).to eq("Jul 15, 2026 @ 12:30pm")
    end

    it "does not include extra whitespace" do
      dt = Time.utc(2026, 3, 5, 14, 5, 0)
      result = helper.format_datetime(dt)
      expect(result).not_to match(/\s{2,}/)
    end
  end

  describe "#status_badge_color" do
    it "returns orange for booked" do
      expect(helper.status_badge_color("booked")).to include("orange")
    end

    it "returns gray for lost_no_contact" do
      expect(helper.status_badge_color("lost_no_contact")).to include("gray")
    end

    it "returns a default for unknown statuses" do
      expect(helper.status_badge_color("unknown")).to eq("bg-gray-100 text-gray-800")
    end
  end

  describe "#format_date" do
    it "returns em dash for nil" do
      expect(helper.format_date(nil)).to eq("—")
    end

    it "formats a date" do
      expect(helper.format_date(Date.new(2026, 8, 15))).to eq("Aug 15, 2026")
    end

    it "formats a datetime as date only" do
      dt = Time.utc(2026, 8, 15, 23, 59, 0)
      expect(helper.format_date(dt)).to eq("Aug 15, 2026")
    end
  end
end
