class CustomerMatcher
  def self.match_or_create(lead)
    new(lead).call
  end

  def initialize(lead)
    @lead = lead
  end

  def call
    return nil if @lead.email.blank? && @lead.phone.blank?

    find_by_exact_email || find_by_exact_phone || create_customer
  end

  def self.find_matches(email: nil, phone: nil)
    results = []

    if email.present?
      results.concat Customer.where("LOWER(email) = LOWER(?)", email).limit(3).to_a
    end

    if phone.present?
      normalized = phone.gsub(/[^0-9]/, "")
      results.concat Customer.where("REGEXP_REPLACE(phone, '[^0-9]', '', 'g') = ?", normalized).limit(3).to_a
    end

    results.uniq
  end

  private

  def find_by_exact_email
    return nil if @lead.email.blank?

    Customer.where("LOWER(email) = LOWER(?)", @lead.email).first
  end

  def find_by_exact_phone
    return nil if @lead.phone.blank?

    normalized = @lead.phone.gsub(/[^0-9]/, "")
    Customer.where("REGEXP_REPLACE(phone, '[^0-9]', '', 'g') = ?", normalized).first
  end

  def create_customer
    Customer.create!(
      first_name: @lead.first_name,
      last_name: @lead.last_name,
      email: @lead.email,
      phone: @lead.phone,
      address_street: @lead.address_street,
      address_street2: @lead.address_street2,
      address_city: @lead.address_city,
      address_state: @lead.address_state,
      address_zip: @lead.address_zip
    )
  end
end
