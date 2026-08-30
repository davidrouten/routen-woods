require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:admin) { create(:user, :admin) }
  let(:lead) do
    create(:lead,
      first_name: "Jane",
      last_name: "Smith",
      email: "jane@example.com",
      phone: "813-555-0100",
      services_interested_in: ["cabinet_refacing"],
      budget_range: "15_20k",
      timeframe: "asap",
      address_street: "1050 Water St.",
      address_city: "Tampa",
      address_state: "FL",
      address_zip: "33602",
      message: "I need my cabinets refaced"
    )
  end

  describe "#notify" do
    let(:mail) do
      NotificationMailer.with(
        event: "new_lead",
        lead: lead,
        user: admin,
        context: {}
      ).notify
    end

    it "includes budget in the email body" do
      expect(mail.html_part.body.to_s).to include("$15,000 - $20,000")
    end

    it "includes timeframe in the email body" do
      expect(mail.html_part.body.to_s).to include("ASAP")
    end

    it "includes location in the email body" do
      expect(mail.html_part.body.to_s).to include("1050 Water St.")
      expect(mail.html_part.body.to_s).to include("Tampa")
    end

    it "renders phone as a clickable tel: link with formatted label" do
      expect(mail.html_part.body.to_s).to include('href="tel:+18135550100"')
      expect(mail.html_part.body.to_s).to include("(813) 555-0100")
    end

    it "includes the urgent banner for ASAP timeframe" do
      expect(mail.html_part.body.to_s).to include("URGENT")
      expect(mail.html_part.body.to_s).to include("Call back immediately")
    end

    it "includes budget in the text part" do
      expect(mail.text_part.body.to_s).to include("$15,000 - $20,000")
    end

    it "includes the urgent banner in the text part" do
      expect(mail.text_part.body.to_s).to include("URGENT")
    end

    context "with within_month timeframe" do
      let(:lead) { create(:lead, timeframe: "within_month") }

      it "shows the urgent banner" do
        expect(mail.html_part.body.to_s).to include("URGENT")
        expect(mail.html_part.body.to_s).to include("Call back immediately")
      end
    end

    context "with a non-urgent timeframe" do
      let(:lead) do
        create(:lead,
          timeframe: "1_3_months",
          budget_range: "5_10k"
        )
      end

      it "does not include the urgent banner" do
        expect(mail.html_part.body.to_s).not_to include("URGENT")
      end

      it "still includes the timeframe" do
        expect(mail.html_part.body.to_s).to include("1-3 months")
      end
    end

    context "with no budget or timeframe" do
      let(:lead) { create(:lead, budget_range: nil, timeframe: nil) }

      it "omits budget and timeframe rows" do
        expect(mail.html_part.body.to_s).not_to include("Budget:")
        expect(mail.html_part.body.to_s).not_to include("Timeframe:")
      end

      it "shows no urgency banner" do
        expect(mail.html_part.body.to_s).not_to include("URGENT")
      end
    end
  end
end
