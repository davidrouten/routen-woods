class ProcessInboundLeadJob < ApplicationJob
  queue_as :default

  MAPPERS = {
    InboundLead::SOURCE_ANGI => InboundLeadMappers::Angi
  }.freeze

  retry_on StandardError, wait: :polynomially_longer, attempts: 3 do |job, error|
    inbound_lead = job.arguments.first
    inbound_lead.mark_failed!
    Rails.logger.error("[ProcessInboundLead] Gave up on InboundLead##{inbound_lead.id}: #{error.message}")
  end

  def perform(inbound_lead)
    return if inbound_lead.processed?

    mapper = MAPPERS.fetch(inbound_lead.source).new(inbound_lead)
    attrs = mapper.to_lead_attributes

    existing = find_existing_lead(attrs)
    if existing
      inbound_lead.mark_processed!(existing)
      Rails.logger.info("[ProcessInboundLead] Linked InboundLead##{inbound_lead.id} to existing Lead##{existing.id}")
      return
    end

    lead = Lead.create!(attrs)
    inbound_lead.mark_processed!(lead)

    Rails.logger.info("[ProcessInboundLead] Created Lead##{lead.id} from InboundLead##{inbound_lead.id} (#{inbound_lead.source})")
  end

  private

  def find_existing_lead(attrs)
    return unless attrs[:lead_external_source_id].present?

    Lead.find_by(
      lead_external_source: attrs[:lead_external_source],
      lead_external_source_id: attrs[:lead_external_source_id]
    )
  end
end
