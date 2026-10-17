require "rails_helper"

RSpec.describe "UUID v7 primary keys" do
  UUID_V7 = /\A\h{8}-\h{4}-7\h{3}-[89ab]\h{3}-\h{12}\z/

  it "gives new records a v7 UUID" do
    expect(create(:lead).id).to match(UUID_V7)
    expect(create(:invoice_line_item).id).to match(UUID_V7)
  end

  it "keeps a caller-supplied id" do
    id = SecureRandom.uuid_v7
    expect(create(:customer, id: id).id).to eq(id)
  end

  it "orders by id in creation order" do
    leads = Array.new(5) { create(:lead) }
    expect(Lead.order(:id).to_a).to eq(leads)
    expect(Lead.last).to eq(leads.last)
  end

  it "uses the UUID in URLs and HTML element ids" do
    lead = create(:lead)

    expect(Rails.application.routes.url_helpers.admin_lead_path(lead)).to eq("/admin/leads/#{lead.id}")
    expect(ActionView::RecordIdentifier.dom_id(lead)).to eq("lead_#{lead.id}")
  end

  it "treats a non-UUID lookup as not found" do
    expect { Lead.find("12") }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "leaves tables with integer ids alone (Ahoy)" do
    first = Ahoy::Visit.create!(visit_token: "a", visitor_token: "v")
    second = Ahoy::Visit.create!(visit_token: "b", visitor_token: "v")

    expect(first.id).to be_a(Integer)
    expect(second.id).to eq(first.id + 1)
  end

  it "links Active Storage files and polymorphic owners to UUID records" do
    project = create(:project)
    attachment = create(:attachment, attachable: project)

    expect(attachment.file.attachment.record_id).to eq(attachment.id)
    expect(Attachment.find(attachment.id).file).to be_attached
    expect(project.attachments).to eq([attachment])
  end
end
