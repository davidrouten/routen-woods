require "rails_helper"

RSpec.describe Schedule do
  def schedule(start_date:, duration_days:, work_saturdays: false)
    described_class.new(start_date: start_date, duration_days: duration_days, work_saturdays: work_saturdays)
  end

  describe "#scheduled?" do
    it "returns true with start date and positive duration" do
      expect(schedule(start_date: Date.parse("2026-09-07"), duration_days: 3)).to be_scheduled
    end

    it "returns false without start date" do
      expect(schedule(start_date: nil, duration_days: 3)).not_to be_scheduled
    end

    it "returns false without duration" do
      expect(schedule(start_date: Date.parse("2026-09-07"), duration_days: nil)).not_to be_scheduled
    end
  end

  describe "#end_date" do
    it "returns nil when not scheduled" do
      expect(schedule(start_date: nil, duration_days: 3).end_date).to be_nil
    end

    it "returns start date for a 1-day project" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 1)
      expect(s.end_date).to eq(Date.parse("2026-09-07"))
    end

    it "returns start date for a half-day project" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 0.5)
      expect(s.end_date).to eq(Date.parse("2026-09-07"))
    end

    it "spans consecutive work days" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 3)
      expect(s.end_date).to eq(Date.parse("2026-09-09"))
    end

    it "skips Saturday and Sunday" do
      s = schedule(start_date: Date.parse("2026-09-11"), duration_days: 3)
      expect(s.end_date).to eq(Date.parse("2026-09-15"))
    end

    it "includes Saturday when work_saturdays is true" do
      s = schedule(start_date: Date.parse("2026-09-11"), duration_days: 3, work_saturdays: true)
      expect(s.end_date).to eq(Date.parse("2026-09-14"))
    end

    it "handles multi-week projects" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 10)
      expect(s.end_date).to eq(Date.parse("2026-09-18"))
    end

    it "handles half-day spanning a weekend" do
      s = schedule(start_date: Date.parse("2026-09-11"), duration_days: 1.5)
      expect(s.end_date).to eq(Date.parse("2026-09-14"))
    end
  end

  describe "#work_days" do
    it "returns empty array when not scheduled" do
      expect(schedule(start_date: nil, duration_days: 3).work_days).to eq([])
    end

    it "lists all work days for a week-long project" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 5)
      expect(s.work_days).to eq([
        Date.parse("2026-09-07"),
        Date.parse("2026-09-08"),
        Date.parse("2026-09-09"),
        Date.parse("2026-09-10"),
        Date.parse("2026-09-11")
      ])
    end

    it "skips weekends" do
      s = schedule(start_date: Date.parse("2026-09-11"), duration_days: 3)
      expect(s.work_days).to eq([
        Date.parse("2026-09-11"),
        Date.parse("2026-09-14"),
        Date.parse("2026-09-15")
      ])
    end

    it "includes Saturday when enabled" do
      s = schedule(start_date: Date.parse("2026-09-11"), duration_days: 3, work_saturdays: true)
      expect(s.work_days).to eq([
        Date.parse("2026-09-11"),
        Date.parse("2026-09-12"),
        Date.parse("2026-09-14")
      ])
    end
  end

  describe "#formatted" do
    it "returns nil without start date" do
      expect(schedule(start_date: nil, duration_days: 3).formatted).to be_nil
    end

    it "shows single day for 1-day project" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 1)
      expect(s.formatted).to eq("Mon, Sep 7 (1 day)")
    end

    it "shows range for multi-day project" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: 5)
      expect(s.formatted).to eq("Mon, Sep 7 - Fri, Sep 11 (5 days)")
    end

    it "shows start date only when no duration" do
      s = schedule(start_date: Date.parse("2026-09-07"), duration_days: nil)
      expect(s.formatted).to eq("Mon, Sep 7")
    end
  end

  describe "#formatted_duration" do
    it "formats whole days" do
      expect(schedule(start_date: Date.today, duration_days: 5).formatted_duration).to eq("5 days")
    end

    it "formats fractional days" do
      expect(schedule(start_date: Date.today, duration_days: 2.5).formatted_duration).to eq("2.5 days")
    end

    it "formats 1 day as singular" do
      expect(schedule(start_date: Date.today, duration_days: 1).formatted_duration).to eq("1 day")
    end

    it "returns nil without duration" do
      expect(schedule(start_date: Date.today, duration_days: nil).formatted_duration).to be_nil
    end
  end
end
