require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:leads).dependent(:nullify) }
    it { is_expected.to have_many(:projects).dependent(:nullify) }
    it { is_expected.to have_many(:invoices).through(:projects) }
  end

  describe "#full_name" do
    it "joins first and last name" do
      customer = build(:customer, first_name: "John", last_name: "Doe")
      expect(customer.full_name).to eq("John Doe")
    end

    it "returns first name only when last name is blank" do
      customer = build(:customer, first_name: "John", last_name: nil)
      expect(customer.full_name).to eq("John")
    end
  end

  describe "#total_revenue" do
    it "sums agreed_price across projects" do
      customer = create(:customer)
      create(:project, customer: customer, agreed_price: 1500)
      create(:project, customer: customer, agreed_price: 2500)

      expect(customer.total_revenue).to eq(4000)
    end

    it "returns 0 with no projects" do
      customer = create(:customer)
      expect(customer.total_revenue).to eq(0)
    end
  end

  describe "#total_collected" do
    it "sums amount_paid across invoices" do
      customer = create(:customer)
      project = create(:project, customer: customer)
      create(:invoice, project: project, amount_paid: 500, total: 1000)
      create(:invoice, project: project, amount_paid: 300, total: 800)

      expect(customer.total_collected).to eq(800)
    end
  end

  describe "#total_outstanding" do
    it "returns revenue minus collected" do
      customer = create(:customer)
      project = create(:project, customer: customer, agreed_price: 5000)
      create(:invoice, project: project, amount_paid: 2000, total: 5000)

      expect(customer.total_outstanding).to eq(3000)
    end
  end

  describe "Searchable" do
    it "returns full_name as search_title" do
      customer = build(:customer, first_name: "Jane", last_name: "Doe")
      expect(customer.search_title).to eq("Jane Doe")
    end

    it "returns admin path as search_url" do
      customer = create(:customer)
      expect(customer.search_url).to eq("/admin/customers/#{customer.id}")
    end
  end
end
