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

  describe "attachments" do
    it "has many attachments" do
      project = create(:project)
      attachment = create(:attachment, attachable: project)
      expect(project.attachments).to include(attachment)
    end

    it "destroys attachments when project is destroyed" do
      project = create(:project)
      create(:attachment, attachable: project)
      expect { project.destroy }.to change(Attachment, :count).by(-1)
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

  describe "discard (archive)" do
    let(:project) { create(:project) }

    it "can be discarded and undiscarded" do
      project.discard!
      expect(project).to be_discarded
      expect(Project.kept).not_to include(project)
      expect(Project.discarded).to include(project)

      project.undiscard!
      expect(project).not_to be_discarded
      expect(Project.kept).to include(project)
    end

    it ".active excludes discarded projects" do
      active = create(:project, status: :in_progress)
      discarded = create(:project, status: :in_progress)
      discarded.discard!

      expect(Project.active).to include(active)
      expect(Project.active).not_to include(discarded)
    end

    it "cascade-discards invoices when project is discarded" do
      invoice = create(:invoice, project: project)
      project.discard!
      expect(invoice.reload).to be_discarded
    end

    it "cascade-discards order forms when project is discarded" do
      order_form = create(:order_form, project: project)
      project.discard!
      expect(order_form.reload).to be_discarded
    end

    it "does not cascade-discard attachments or notes" do
      attachment = create(:attachment, attachable: project)
      project.discard!
      expect(Attachment.exists?(attachment.id)).to be true
      expect(attachment.reload).to be_present
    end

    describe "scoped associations" do
      it "project.invoices returns only kept invoices" do
        kept_invoice = create(:invoice, project: project)
        discarded_invoice = create(:invoice, project: project)
        discarded_invoice.discard!

        expect(project.invoices.reload).to include(kept_invoice)
        expect(project.invoices.reload).not_to include(discarded_invoice)
      end

      it "project.discarded_invoices returns only discarded invoices" do
        kept_invoice = create(:invoice, project: project)
        discarded_invoice = create(:invoice, project: project)
        discarded_invoice.discard!

        expect(project.discarded_invoices).to include(discarded_invoice)
        expect(project.discarded_invoices).not_to include(kept_invoice)
      end

      it "project.order_forms returns only kept order forms" do
        kept_of = create(:order_form, project: project)
        discarded_of = create(:order_form, project: project)
        discarded_of.discard!

        expect(project.order_forms.reload).to include(kept_of)
        expect(project.order_forms.reload).not_to include(discarded_of)
      end

      it "project.discarded_order_forms returns only discarded order forms" do
        kept_of = create(:order_form, project: project)
        discarded_of = create(:order_form, project: project)
        discarded_of.discard!

        expect(project.discarded_order_forms).to include(discarded_of)
        expect(project.discarded_order_forms).not_to include(kept_of)
      end
    end
  end

  describe "before_destroy guard" do
    it "blocks destroy when invoices have payments" do
      project = create(:project)
      invoice = create(:invoice, project: project)
      create(:payment, invoice: invoice)

      expect(project.destroy).to be false
      expect(project.errors[:base]).to include("Cannot delete a project with invoices that have payments")
      expect(Project.exists?(project.id)).to be true
    end

    it "blocks destroy even when the invoice is discarded" do
      project = create(:project)
      invoice = create(:invoice, project: project)
      create(:payment, invoice: invoice)
      invoice.discard!

      expect(project.destroy).to be false
      expect(Project.exists?(project.id)).to be true
    end

    it "allows destroy when invoices have no payments" do
      project = create(:project)
      create(:invoice, project: project)

      expect { project.destroy }.to change(Project, :count).by(-1)
    end

    it "allows destroy when project has no invoices" do
      project = create(:project)
      expect { project.destroy }.to change(Project, :count).by(-1)
    end
  end
end
