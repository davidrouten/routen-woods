class BackfillCustomersFromLeads < ActiveRecord::Migration[8.1]
  def up
    Lead.where(spam: false, customer_id: nil).find_each do |lead|
      customer = CustomerMatcher.match_or_create(lead)
      lead.update_column(:customer_id, customer.id) if customer
    end

    Project.where(customer_id: nil).where.not(lead_id: nil).includes(:lead).find_each do |project|
      next unless project.lead&.customer_id
      project.update_column(:customer_id, project.lead.customer_id)
    end

    # Orphan projects (no lead) are left without a customer — admins can link one manually
    Project.where(customer_id: nil, lead_id: nil).where.not(email: [nil, ""]).find_each do |project|
      customer = Customer.where("LOWER(email) = LOWER(?)", project.email).first
      project.update_column(:customer_id, customer.id) if customer
    end
  end

  def down
    Lead.where.not(customer_id: nil).update_all(customer_id: nil)
    Project.where.not(customer_id: nil).update_all(customer_id: nil)
    Customer.delete_all
  end
end
