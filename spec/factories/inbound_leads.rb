FactoryBot.define do
  factory :inbound_lead do
    source { "angi" }
    external_id { rand(100_000_000..999_999_999).to_s }
    status { "pending" }
    payload do
      {
        # Always present fields
        "name" => "Jane Doe",                        # Homeowner full name
        "firstName" => "Jane",                       # Sometimes absent
        "lastName" => "Doe",                         # Sometimes absent
        "address" => "123 Main Street",              # Street address
        "city" => "Denver",
        "stateProvince" => "CO",                     # Two-letter state code
        "postalCode" => "80210",                     # Zip code
        "primaryPhone" => "3031234567",              # Always present, primary contact number
        "phoneExt" => "1234",                        # Sometimes absent
        "secondaryPhone" => "3037654321",            # Sometimes absent
        "secondaryPhoneExt" => "5678",               # Sometimes absent
        "email" => "janedoe@gmail.com",              # Always present
        "srOid" => 123_456_789,                      # Unique service request ID (Angi's internal)
        "leadOid" => rand(100_000_000..999_999_999), # Unique lead ID — use for dedup
        "fee" => 25.67,                              # Lead fee charged to the pro
        "taskName" => "Cabinet Refacing",            # Service the homeowner requested
        "comments" => "Looking for kitchen cabinet refacing for our home.", # Homeowner-provided notes
        "matchType" => "Lead",                       # How the lead was matched (e.g. "Lead", "Direct Match")
        "leadDescription" => "Standard",             # Lead type (e.g. "Standard", "Service Request")
        "spEntityId" => 12_345_678,                  # Pro's business ID on Angi — sometimes absent
        "spCompanyName" => "Routen Woods",           # Pro's business name as registered on Angi
        "contactStatus" => "New Appt - Transferred", # Lead contact status — sometimes absent
        "primaryPhoneDetails" => {                   # Phone metadata — sometimes absent
          "maskedNumber" => false                     # Whether Angi is masking the homeowner's real number
        },
        "crmKey" => "abcd-12345",                    # Pro-defined routing identifier — sometimes absent
        "leadSource" => "HomeAdvisor",               # Origin platform (e.g. "HomeAdvisor", "Angi") — sometimes absent
        "trustedFormUrl" => "https://cert.trustedform.com/xxz1z51db5ed50eb17992be2686166f4fc87f11c", # TCPA compliance certificate — sometimes absent
        "automatedContactCompliant" => true,         # Whether homeowner consented to automated messages (calls/texts)
        "automatedContactConsentId" => "223e4567-e89b-12d3-a456-426614174333", # Compliance reference ID — sometimes absent
        "interview" => [                             # Q&A from homeowner intake — sometimes absent
          { "question" => "What type of project?", "answer" => "Kitchen cabinets" },
          { "question" => "When do you want the pro to begin work?", "answer" => "More than 2 weeks" },
          { "question" => "What is your timeline?", "answer" => "Within a month" }
        ]
      }
    end
  end
end
