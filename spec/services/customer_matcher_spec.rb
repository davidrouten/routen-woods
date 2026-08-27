require "rails_helper"

RSpec.describe CustomerMatcher do
  describe ".match_or_create" do
    before do
      allow_any_instance_of(Lead).to receive(:link_to_customer)
    end

    it "creates a new customer when no match exists" do
      lead = create(:lead, email: "new@example.com", phone: "813-555-0001")

      expect { CustomerMatcher.match_or_create(lead) }.to change(Customer, :count).by(1)

      customer = Customer.last
      expect(customer.first_name).to eq(lead.first_name)
      expect(customer.last_name).to eq(lead.last_name)
      expect(customer.email).to eq(lead.email)
      expect(customer.phone).to eq(lead.phone)
    end

    it "matches on exact email (case-insensitive)" do
      existing = create(:customer, email: "John@Example.com")
      lead = create(:lead, email: "john@example.com", phone: "999-999-9999")

      result = CustomerMatcher.match_or_create(lead)

      expect(result).to eq(existing)
    end

    it "matches on phone with different formatting" do
      existing = create(:customer, email: "other@example.com", phone: "(813) 555-0100")
      lead = create(:lead, email: "different@example.com", phone: "8135550100")

      result = CustomerMatcher.match_or_create(lead)

      expect(result).to eq(existing)
    end

    it "prefers email match over phone match" do
      email_customer = create(:customer, email: "match@example.com", phone: "111-111-1111")
      _phone_customer = create(:customer, email: "other@example.com", phone: "813-555-0100")
      lead = create(:lead, email: "match@example.com", phone: "813-555-0100")

      result = CustomerMatcher.match_or_create(lead)

      expect(result).to eq(email_customer)
    end

    it "returns nil when lead has no email or phone" do
      lead = create(:lead, phone: "813-555-0001")
      lead.update_columns(email: nil, phone: nil)

      expect(CustomerMatcher.match_or_create(lead)).to be_nil
    end

    it "is idempotent — same email returns same customer" do
      lead1 = create(:lead, email: "repeat@example.com")
      lead2 = create(:lead, email: "repeat@example.com")

      customer1 = CustomerMatcher.match_or_create(lead1)
      customer2 = CustomerMatcher.match_or_create(lead2)

      expect(customer1).to eq(customer2)
      expect(Customer.where("LOWER(email) = ?", "repeat@example.com").count).to eq(1)
    end

    it "copies address fields from lead to new customer" do
      lead = create(:lead,
        address_street: "123 Oak St",
        address_city: "Tampa",
        address_state: "FL",
        address_zip: "33601"
      )

      customer = CustomerMatcher.match_or_create(lead)

      expect(customer.address_street).to eq("123 Oak St")
      expect(customer.address_city).to eq("Tampa")
      expect(customer.address_state).to eq("FL")
      expect(customer.address_zip).to eq("33601")
    end
  end

  describe ".find_matches" do
    it "finds customers by email" do
      customer = create(:customer, email: "test@example.com")
      results = CustomerMatcher.find_matches(email: "test@example.com")

      expect(results).to include(customer)
    end

    it "finds customers by phone" do
      customer = create(:customer, phone: "(813) 555-0100")
      results = CustomerMatcher.find_matches(phone: "8135550100")

      expect(results).to include(customer)
    end

    it "returns empty array when no matches" do
      results = CustomerMatcher.find_matches(email: "nobody@example.com")
      expect(results).to be_empty
    end

    it "deduplicates results matching on both email and phone" do
      customer = create(:customer, email: "test@example.com", phone: "813-555-0100")
      results = CustomerMatcher.find_matches(email: "test@example.com", phone: "8135550100")

      expect(results).to eq([customer])
    end
  end
end
