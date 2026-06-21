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
end
