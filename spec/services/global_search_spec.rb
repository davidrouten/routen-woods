require "rails_helper"

RSpec.describe GlobalSearch do
  let(:user) { create(:user, first_name: "Sarah", last_name: "Connor") }

  before do
    allow_any_instance_of(Lead).to receive(:link_to_customer)
  end

  describe "#results" do
    it "returns empty for queries shorter than 2 characters" do
      create(:lead, first_name: "A")
      expect(GlobalSearch.new("A").results).to eq([])
    end

    it "returns empty for blank query" do
      expect(GlobalSearch.new("").results).to eq([])
      expect(GlobalSearch.new("   ").results).to eq([])
    end

    # -- Lead search --

    context "lead: matching by name" do
      it "finds leads by first name" do
        create(:lead, first_name: "Marcus", last_name: "Green")
        results = GlobalSearch.new("Marcus").results
        expect(results.length).to eq(1)
        expect(results.first[:title]).to eq("Marcus Green")
        expect(results.first[:subtitle]).to eq("Name")
        expect(results.first[:type]).to eq("Lead")
      end

      it "finds leads by last name" do
        create(:lead, first_name: "Amy", last_name: "Vandenberg")
        results = GlobalSearch.new("Vandenberg").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Name")
      end

      it "is case insensitive" do
        create(:lead, first_name: "Marcus")
        expect(GlobalSearch.new("marcus").results.length).to eq(1)
        expect(GlobalSearch.new("MARCUS").results.length).to eq(1)
      end
    end

    context "lead: matching by email" do
      it "finds leads by email" do
        create(:lead, first_name: "Tom", email: "tom@bigbend.com")
        results = GlobalSearch.new("bigbend").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Email: tom@bigbend.com")
      end
    end

    context "lead: matching by phone" do
      it "finds leads by phone number" do
        create(:lead, first_name: "Tom", phone: "248-999-1234")
        results = GlobalSearch.new("999-1234").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Phone: 248-999-1234")
      end
    end

    context "lead: matching by address" do
      it "finds leads by city" do
        create(:lead, first_name: "Tom", address_city: "Oxford")
        results = GlobalSearch.new("Oxford").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to start_with("Address:")
        expect(results.first[:subtitle]).to include("Oxford")
      end

      it "finds leads by street" do
        create(:lead, first_name: "Tom", address_street: "123 Maple Lane")
        results = GlobalSearch.new("Maple").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to start_with("Address:")
      end

      it "finds leads by zip code" do
        create(:lead, first_name: "Tom", address_zip: "48371")
        results = GlobalSearch.new("48371").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to include("48371")
      end

      it "finds leads by state" do
        create(:lead, first_name: "Tom", last_name: "Doe", address_state: "TX")
        results = GlobalSearch.new("TX").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to start_with("Address:")
      end
    end

    context "lead: matching by message" do
      it "finds leads by message content" do
        create(:lead, first_name: "Tom", message: "Need help with my superstar kitchen project")
        results = GlobalSearch.new("superstar").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to start_with("Message:")
        expect(results.first[:subtitle]).to include("superstar")
      end
    end

    context "lead: matching by notes" do
      it "finds leads through note body text" do
        lead = create(:lead, first_name: "Tom")
        create(:note, notable: lead, user: user, body: "Discussed the marble countertop options")
        results = GlobalSearch.new("marble").results
        expect(results.length).to eq(1)
        expect(results.first[:title]).to eq("Tom Smith")
        expect(results.first[:subtitle]).to start_with("Note:")
        expect(results.first[:subtitle]).to include("marble")
      end

      it "finds leads through note author name" do
        lead = create(:lead, first_name: "Tom")
        create(:note, notable: lead, user: user, body: "Called the customer")
        results = GlobalSearch.new("Sarah").results
        expect(results.length).to eq(1)
        expect(results.first[:title]).to eq("Tom Smith")
        expect(results.first[:subtitle]).to start_with("Note by Sarah Connor:")
      end

      it "links to the parent lead, not the note" do
        lead = create(:lead, first_name: "Tom")
        create(:note, notable: lead, user: user, body: "This is a unique findable note")
        results = GlobalSearch.new("unique findable").results
        expect(results.first[:url]).to eq("/admin/leads/#{lead.id}")
      end
    end

    context "lead: deduplication" do
      it "returns one result per lead even with multiple matches" do
        lead = create(:lead, first_name: "Wilson", email: "wilson@test.com", message: "Wilson project")
        create(:note, notable: lead, user: user, body: "Wilson called back")
        results = GlobalSearch.new("Wilson").results
        lead_results = results.select { |r| r[:type] == "Lead" }
        expect(lead_results.length).to eq(1)
        expect(lead_results.first[:match_contexts]).to include("Name")
      end

      it "uses the highest-priority match as subtitle" do
        create(:lead, first_name: "Wilson", message: "Wilson project details")
        results = GlobalSearch.new("Wilson").results
        lead_result = results.find { |r| r[:type] == "Lead" }
        expect(lead_result[:subtitle]).to eq("Name")
      end

      it "collects all match contexts" do
        create(:lead, first_name: "Wilson", email: "wilson@test.com")
        results = GlobalSearch.new("Wilson").results
        lead_result = results.find { |r| r[:type] == "Lead" }
        expect(lead_result[:match_contexts]).to include("Name")
        expect(lead_result[:match_contexts]).to include("Email: wilson@test.com")
      end
    end

    context "lead: spam exclusion" do
      it "excludes spam leads from direct matches" do
        create(:lead, :spam, first_name: "Spammy")
        expect(GlobalSearch.new("Spammy").results).to be_empty
      end

      it "excludes spam leads from note matches" do
        lead = create(:lead, :spam, first_name: "Spambot")
        create(:note, notable: lead, user: user, body: "Flagged as spam")
        expect(GlobalSearch.new("Flagged").results).to be_empty
      end
    end

    # -- Project search --

    context "project: matching by title" do
      it "finds projects by title" do
        create(:project, title: "Henderson Kitchen Reface")
        results = GlobalSearch.new("Henderson").results
        expect(results.length).to eq(1)
        expect(results.first[:type]).to eq("Project")
        expect(results.first[:title]).to eq("Henderson Kitchen Reface")
        expect(results.first[:subtitle]).to eq("Title")
        expect(results.first[:url]).to start_with("/admin/projects/")
      end
    end

    context "project: matching by description" do
      it "finds projects by description content" do
        create(:project, title: "Kitchen Job", description: "Full quartzite countertop replacement")
        results = GlobalSearch.new("quartzite").results
        expect(results.length).to eq(1)
        expect(results.first[:type]).to eq("Project")
        expect(results.first[:subtitle]).to start_with("Description:")
        expect(results.first[:subtitle]).to include("quartzite")
      end
    end

    context "project: matching by contact" do
      it "finds projects by email" do
        create(:project, title: "Kitchen Job", email: "client@hendersonfamily.com")
        results = GlobalSearch.new("hendersonfamily").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Contact: client@hendersonfamily.com")
      end

      it "finds projects by phone" do
        create(:project, title: "Kitchen Job", phone: "248-777-9999")
        results = GlobalSearch.new("777-9999").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Contact: 248-777-9999")
      end
    end

    context "project: matching by address" do
      it "finds projects by address" do
        create(:project, title: "Kitchen Job", address: "456 Elm Street, Rochester MI")
        results = GlobalSearch.new("Elm Street").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to start_with("Address:")
      end
    end

    context "project: matching by notes" do
      it "finds projects through note body text" do
        project = create(:project, title: "Big Renovation")
        create(:note, notable: project, user: user, body: "Customer wants waterfall edge on island")
        results = GlobalSearch.new("waterfall").results
        expect(results.length).to eq(1)
        expect(results.first[:type]).to eq("Project")
        expect(results.first[:title]).to eq("Big Renovation")
        expect(results.first[:subtitle]).to start_with("Note:")
        expect(results.first[:url]).to eq("/admin/projects/#{project.id}")
      end
    end

    context "project: deduplication" do
      it "returns one result per project even with multiple matches" do
        project = create(:project, title: "Zenith Remodel", description: "Zenith kitchen update")
        create(:note, notable: project, user: user, body: "Zenith client confirmed")
        results = GlobalSearch.new("Zenith").results
        project_results = results.select { |r| r[:type] == "Project" }
        expect(project_results.length).to eq(1)
        expect(project_results.first[:match_contexts]).to include("Title")
      end
    end

    context "project: status" do
      it "includes the project status" do
        create(:project, title: "Henderson Job", status: :in_progress)
        result = GlobalSearch.new("Henderson").results.first
        expect(result[:status]).to eq("in_progress")
      end
    end

    # -- Invoice search --

    context "invoice: matching by invoice number" do
      it "finds invoices by invoice number" do
        invoice = create(:invoice, invoice_number: "INV-2050")
        results = GlobalSearch.new("INV-2050").results
        expect(results.length).to eq(1)
        expect(results.first[:type]).to eq("Invoice")
        expect(results.first[:title]).to eq("INV-2050")
        expect(results.first[:subtitle]).to eq("Invoice #")
      end

      it "finds invoices by partial invoice number" do
        create(:invoice, invoice_number: "INV-2050")
        results = GlobalSearch.new("2050").results
        expect(results.length).to eq(1)
        expect(results.first[:type]).to eq("Invoice")
      end
    end

    context "invoice: matching by notes field" do
      it "finds invoices by notes content" do
        create(:invoice, invoice_number: "INV-3000", notes: "Deposit received via Zelle transfer")
        results = GlobalSearch.new("Zelle").results
        expect(results.length).to eq(1)
        expect(results.first[:type]).to eq("Invoice")
        expect(results.first[:subtitle]).to start_with("Notes:")
        expect(results.first[:subtitle]).to include("Zelle")
      end
    end

    context "invoice: URL routing" do
      it "routes to project-scoped path when project exists" do
        project = create(:project, title: "Kitchen Job")
        invoice = create(:invoice, invoice_number: "INV-4000", project: project)
        result = GlobalSearch.new("INV-4000").results.first
        expect(result[:url]).to eq("/admin/projects/#{project.id}/invoices/#{invoice.id}")
      end

      it "routes to standalone path when no project" do
        invoice = create(:invoice, invoice_number: "INV-4001", project: nil)
        result = GlobalSearch.new("INV-4001").results.first
        expect(result[:url]).to eq("/admin/invoices/#{invoice.id}")
      end
    end

    context "invoice: status" do
      it "includes the invoice status" do
        create(:invoice, invoice_number: "INV-5000", status: :sent)
        result = GlobalSearch.new("INV-5000").results.first
        expect(result[:status]).to eq("sent")
      end
    end

    # -- Cross-model --

    context "cross-model results" do
      it "returns leads, projects, and invoices together" do
        create(:lead, first_name: "Zenith", last_name: "Corp")
        create(:project, title: "Zenith Remodel")
        results = GlobalSearch.new("Zenith").results
        types = results.map { |r| r[:type] }.uniq
        expect(types).to contain_exactly("Lead", "Project")
      end

      it "orders leads first, then projects, then invoices" do
        create(:project, title: "Alphaville Kitchen")
        create(:lead, first_name: "Alphaville", last_name: "Buyer")
        results = GlobalSearch.new("Alphaville").results
        expect(results.first[:type]).to eq("Lead")
        expect(results.last[:type]).to eq("Project")
      end
    end

    # -- Shared behavior --

    context "result structure" do
      it "includes type, title, subtitle, url, status, and match_contexts for leads" do
        create(:lead, first_name: "Tom", status: :contacted)
        result = GlobalSearch.new("Tom").results.first
        expect(result[:type]).to eq("Lead")
        expect(result[:title]).to be_present
        expect(result[:subtitle]).to be_present
        expect(result[:url]).to start_with("/admin/leads/")
        expect(result[:status]).to eq("contacted")
        expect(result[:match_contexts]).to be_an(Array)
      end

      it "includes type, title, subtitle, url, status, and match_contexts for projects" do
        create(:project, title: "Henderson Job", status: :scheduled)
        result = GlobalSearch.new("Henderson").results.first
        expect(result[:type]).to eq("Project")
        expect(result[:title]).to be_present
        expect(result[:subtitle]).to be_present
        expect(result[:url]).to start_with("/admin/projects/")
        expect(result[:status]).to eq("scheduled")
        expect(result[:match_contexts]).to be_an(Array)
      end
    end

    context "snippet extraction" do
      it "shows context around the match in long text" do
        long_message = "This is a very long message about various topics. " \
                       "Somewhere in the middle we mention superstar quality. " \
                       "And then we keep going with more text after that."
        create(:lead, first_name: "Tom", message: long_message)
        result = GlobalSearch.new("superstar").results.first
        expect(result[:subtitle]).to include("superstar")
        expect(result[:subtitle].length).to be <= 80
      end
    end

    context "limit" do
      it "returns at most LIMIT results across all types" do
        12.times { |i| create(:lead, first_name: "Alex#{i}", email: "alex#{i}@test.com") }
        3.times { |i| create(:project, title: "Alex Project #{i}") }
        results = GlobalSearch.new("Alex").results
        expect(results.length).to be <= GlobalSearch::LIMIT
      end
    end
  end
end
