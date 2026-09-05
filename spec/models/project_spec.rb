require "rails_helper"

RSpec.describe Project do
  describe "validations" do
    it "requires a title" do
      project = build(:project, title: nil)
      expect(project).not_to be_valid
    end

    it "generates a client_token automatically" do
      project = create(:project)
      expect(project.client_token).to be_present
    end
  end

  describe "status transitions" do
    it "starts as scheduled" do
      project = create(:project)
      expect(project).to be_scheduled
    end

    it "#start! moves to in_progress and stamps started_at" do
      project = create(:project)
      project.start!
      expect(project).to be_in_progress
      expect(project.started_at).to be_present
    end

    it "#complete! moves to complete and stamps completed_at" do
      project = create(:project, :in_progress)
      project.complete!
      expect(project).to be_complete
      expect(project.completed_at).to be_present
    end

    it "#mark_paid! moves to paid and stamps paid_at" do
      project = create(:project, :complete)
      project.mark_paid!
      expect(project).to be_paid
      expect(project.paid_at).to be_present
    end
  end

  describe "#balance_remaining" do
    it "calculates balance from agreed price minus deposit" do
      project = build(:project, agreed_price: 7000, deposit_amount: 2000)
      expect(project.balance_remaining).to eq(5000)
    end
  end

  describe "calendar_color" do
    it "auto-assigns a color from the palette on create" do
      project = create(:project)
      expect(project.calendar_color).to be_present
      expect(project.calendar_color).to match(/\A#[0-9A-Fa-f]{6}\z/)
    end

    it "does not overwrite an explicitly set color" do
      project = create(:project, calendar_color: "#FF0000")
      expect(project.calendar_color).to eq("#FF0000")
    end

    it "avoids colors already in use by other projects" do
      first = create(:project)
      second = create(:project)
      expect(second.calendar_color).not_to eq(first.calendar_color)
    end

    it "rejects invalid hex colors" do
      project = build(:project, calendar_color: "not-a-color")
      expect(project).not_to be_valid
      expect(project.errors[:calendar_color]).to be_present
    end

    it "allows blank calendar_color" do
      project = build(:project, calendar_color: "")
      project.valid?
      expect(project.errors[:calendar_color]).to be_empty
    end
  end

  describe "#schedule" do
    it "returns a Schedule built from project attributes" do
      project = build(:project,
        scheduled_start_date: Date.parse("2026-09-07"),
        estimated_duration_days: 5,
        work_saturdays: false)

      sched = project.schedule
      expect(sched).to be_a(Schedule)
      expect(sched.start_date).to eq(Date.parse("2026-09-07"))
      expect(sched.duration_days).to eq(5)
      expect(sched.work_saturdays).to be false
    end
  end
end
