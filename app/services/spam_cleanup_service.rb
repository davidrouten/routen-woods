class SpamCleanupService
  def self.delete_lead(lead)
    new.delete_lead(lead)
  end

  def self.purge_all_spam
    new.purge_all_spam
  end

  def delete_lead(lead)
    customer = lead.customer
    should_delete_customer = lead.customer_will_be_deleted?

    ActiveRecord::Base.transaction do
      lead.destroy!
      customer.destroy! if should_delete_customer
    end
  end

  def purge_all_spam
    spam_leads = Lead.spam_only.includes(:customer)
    auto_detected_customer_ids = spam_leads
      .where("spam_score >= ?", SpamDetector::SPAM_THRESHOLD)
      .where.not(customer_id: nil)
      .distinct
      .pluck(:customer_id)

    leads_deleted = 0
    customers_deleted = 0

    ActiveRecord::Base.transaction do
      leads_deleted = spam_leads.count
      spam_leads.destroy_all

      auto_detected_customer_ids.each do |cid|
        customer = Customer.find_by(id: cid)
        next unless customer
        next if customer.leads.exists?
        customer.destroy!
        customers_deleted += 1
      end
    end

    { leads_deleted: leads_deleted, customers_deleted: customers_deleted }
  end
end
