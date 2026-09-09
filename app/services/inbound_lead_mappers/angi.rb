module InboundLeadMappers
  class Angi
    def initialize(inbound_lead)
      @inbound_lead = inbound_lead
      @payload = inbound_lead.payload
    end

    def to_lead_attributes
      {
        first_name: @payload["firstName"].presence || split_name.first,
        last_name: @payload["lastName"].presence || split_name.last,
        email: @payload["email"],
        phone: @payload["primaryPhone"],
        address_street: @payload["address"],
        address_city: @payload["city"],
        address_state: @payload["stateProvince"],
        address_zip: @payload["postalCode"],
        message: build_message,
        source: "Angi",
        lead_external_source: InboundLead::SOURCE_ANGI,
        lead_external_source_id: @inbound_lead.external_id
      }
    end

    private

    def split_name
      parts = @payload["name"]&.split(" ", 2) || []
      [parts.first, parts.last]
    end

    def build_message
      parts = []
      parts << "Service: #{@payload["taskName"]}" if @payload["taskName"].present?
      parts << @payload["comments"] if @payload["comments"].present?

      if @payload["interview"].is_a?(Array)
        @payload["interview"].each do |qa|
          parts << "Q: #{qa["question"]}\nA: #{qa["answer"]}"
        end
      end

      parts.join("\n\n")
    end
  end
end
