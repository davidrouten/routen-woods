require "rails_helper"

RSpec.describe GlobalSearch do
  let(:user) { create(:user, first_name: "Sarah", last_name: "Connor") }

  describe "#results" do
    it "returns empty for queries shorter than 2 characters" do
      create(:lead, first_name: "A")
      expect(GlobalSearch.new("A").results).to eq([])
    end

    it "returns empty for blank query" do
      expect(GlobalSearch.new("").results).to eq([])
      expect(GlobalSearch.new("   ").results).to eq([])
    end

    context "matching by name" do
      it "finds leads by first name" do
        lead = create(:lead, first_name: "Marcus", last_name: "Green")
        results = GlobalSearch.new("Marcus").results
        expect(results.length).to eq(1)
        expect(results.first[:title]).to eq("Marcus Green")
        expect(results.first[:subtitle]).to eq("Name")
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

    context "matching by email" do
      it "finds leads by email" do
        create(:lead, first_name: "Tom", email: "tom@bigbend.com")
        results = GlobalSearch.new("bigbend").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Email: tom@bigbend.com")
      end
    end

    context "matching by phone" do
      it "finds leads by phone number" do
        create(:lead, first_name: "Tom", phone: "248-999-1234")
        results = GlobalSearch.new("999-1234").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to eq("Phone: 248-999-1234")
      end
    end

    context "matching by address" do
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

    context "matching by message" do
      it "finds leads by message content" do
        create(:lead, first_name: "Tom", message: "Need help with my superstar kitchen project")
        results = GlobalSearch.new("superstar").results
        expect(results.length).to eq(1)
        expect(results.first[:subtitle]).to start_with("Message:")
        expect(results.first[:subtitle]).to include("superstar")
      end
    end

    context "matching by notes" do
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

    context "deduplication" do
      it "returns one result per lead even with multiple matches" do
        lead = create(:lead, first_name: "Wilson", email: "wilson@test.com", message: "Wilson project")
        create(:note, notable: lead, user: user, body: "Wilson called back")
        results = GlobalSearch.new("Wilson").results
        expect(results.length).to eq(1)
        expect(results.first[:match_contexts]).to include("Name")
      end

      it "uses the highest-priority match as subtitle" do
        lead = create(:lead, first_name: "Wilson", message: "Wilson project details")
        results = GlobalSearch.new("Wilson").results
        expect(results.first[:subtitle]).to eq("Name")
      end

      it "collects all match contexts" do
        lead = create(:lead, first_name: "Wilson", email: "wilson@test.com")
        results = GlobalSearch.new("Wilson").results
        expect(results.first[:match_contexts]).to include("Name")
        expect(results.first[:match_contexts]).to include("Email: wilson@test.com")
      end
    end

    context "spam exclusion" do
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

    context "result structure" do
      it "includes type, title, subtitle, url, status, and match_contexts" do
        create(:lead, first_name: "Tom", status: :contacted)
        result = GlobalSearch.new("Tom").results.first
        expect(result[:type]).to eq("Lead")
        expect(result[:title]).to be_present
        expect(result[:subtitle]).to be_present
        expect(result[:url]).to start_with("/admin/leads/")
        expect(result[:status]).to eq("contacted")
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
      it "returns at most LIMIT results" do
        12.times { |i| create(:lead, first_name: "Alex#{i}", email: "alex#{i}@test.com") }
        results = GlobalSearch.new("Alex").results
        expect(results.length).to be <= GlobalSearch::LIMIT
      end
    end
  end
end
