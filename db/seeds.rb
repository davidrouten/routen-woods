puts "Seeding database..."

# Admin user
admin = User.find_or_create_by!(email: "admin@routenwoods.com") do |u|
  u.password = "password123"
  u.first_name = "David"
  u.last_name = "Routen"
  u.admin = true
  u.phone = "+18131111111"
end
puts "  Admin: #{admin.email} / password123"

# Member user
member = User.find_or_create_by!(email: "team@routenwoods.com") do |u|
  u.password = "password123"
  u.first_name = "Team"
  u.last_name = "Member"
  u.admin = false
end
member.grant!(:view, :leads)
member.grant!(:view, :dashboard)
member.grant!(:create, :notes)
member.grant!(:view, :testimonials)
member.grant!(:view, :gallery)
puts "  Member: #{member.email} / password123"

# Notification preferences
NotificationPreference::EVENTS.each do |event|
  NotificationPreference.find_or_create_by!(event_name: event) do |np|
    np.email_enabled = true
    np.sms_enabled = (event == "new_lead")
    np.slack_enabled = true
  end
end
puts "  Notification preferences created"

# Sample testimonials
testimonials = [
  { author_name: "Sarah Johnson", author_title: "Homeowner, Oxford MI", body: "Routen Woods completely transformed our kitchen cabinets. They look brand new! The team was professional, on time, and the quality of work exceeded our expectations. Highly recommend!", rating: 5, featured: true, position: 0 },
  { author_name: "Mike Chen", author_title: "Homeowner, Lake Orion MI", body: "We got quotes from several companies and Routen Woods was the best value by far. The refinishing work is absolutely stunning and has held up beautifully.", rating: 5, featured: true, position: 1 },
  { author_name: "Lisa Martinez", author_title: "Interior Designer, Rochester MI", body: "I recommend Routen Woods to all my clients. Their attention to detail and craftsmanship is unmatched. They treat every cabinet like a work of art.", rating: 5, featured: true, position: 2 },
  { author_name: "Tom Williams", author_title: "Homeowner, Auburn Hills MI", body: "Great experience from start to finish. The staining work on our oak cabinets brought out the natural grain beautifully. Worth every penny.", rating: 4, featured: false, position: 3 },
  { author_name: "Jennifer Adams", author_title: "Homeowner, Clarkston MI", body: "Quick turnaround, fair pricing, and excellent results. Our kitchen looks like it belongs in a magazine now!", rating: 5, featured: false, position: 4 }
]
testimonials.each do |attrs|
  Testimonial.find_or_create_by!(author_name: attrs[:author_name]) { |t| t.assign_attributes(attrs) }
end
puts "  #{testimonials.size} testimonials created"

# Sample leads in various statuses
services = %w[cabinet_refacing cabinet_customization cabinet_repair cabinet_repainting cabinet_installation custom_closets countertops]
lead_data = [
  { first_name: "James", last_name: "Wilson", email: "james.wilson@example.com", phone: "248-555-0101", status: :incoming, service: services[0] },
  { first_name: "Emily", last_name: "Brown", email: "emily.b@example.com", phone: "248-555-0102", status: :incoming, service: services[1] },
  { first_name: "Robert", last_name: "Davis", email: "rdavis@example.com", phone: "248-555-0103", status: :contacted, service: services[2] },
  { first_name: "Amanda", last_name: "Garcia", email: "agarcia@example.com", phone: "248-555-0104", status: :scheduled, service: services[0] },
  { first_name: "David", last_name: "Miller", email: "dmiller@example.com", phone: "248-555-0105", status: :quoted, service: services[3] },
  { first_name: "Jessica", last_name: "Taylor", email: "jtaylor@example.com", phone: "248-555-0106", status: :booked, service: services[0] },
  { first_name: "Chris", last_name: "Anderson", email: "canderson@example.com", phone: "248-555-0107", status: :completed, service: services[1] },
  { first_name: "Maria", last_name: "Thomas", email: "mthomas@example.com", phone: "248-555-0108", status: :lost, service: services[2] }
]

lead_data.each do |data|
  lead = Lead.find_or_create_by!(email: data[:email]) do |l|
    l.first_name = data[:first_name]
    l.last_name = data[:last_name]
    l.phone = data[:phone]
    l.services_interested_in = [data[:service]]
    l.message = "I'm interested in #{data[:service].titleize.downcase} for my kitchen. Can you provide a quote?"
    l.source = "website"
    l.status = data[:status]
  end
  lead.notes.find_or_create_by!(note_type: "system") do |n|
    n.body = "Lead submitted via website contact form."
    n.user = admin
  end
end
puts "  #{lead_data.size} sample leads created"

# Spam leads (auto-detected) with customers for testing deletion
spam_data = [
  { first_name: "Buy", last_name: "Viagra", email: "buyviagraonline@spam.net", phone: "000-000-0001", message: "Free viagra bitcoin lottery winner! Click here for free money!", honeypot_value: "gotcha" },
  { first_name: "Crypto", last_name: "Winner", email: "crypto12345678@spam.net", phone: "000-000-0002", message: "You won the bitcoin lottery! Free crypto!", honeypot_value: "gotcha" },
  { first_name: "asdf", last_name: "asdf", email: "bot99999@spam.net", phone: "000-000-0003", message: "click here free money viagra", honeypot_value: "gotcha" },
  { first_name: "Test", last_name: "Spambot", email: "spambot@example.net", phone: "000-000-0004", message: "Free lottery winner", honeypot_value: "gotcha" },
  { first_name: "xxxxx", last_name: "xxxxx", email: "xxxxx12345@spam.net", phone: "000-000-0005", message: "cialis bitcoin free money click", honeypot_value: "gotcha" }
]

spam_data.each do |data|
  next if Lead.exists?(email: data[:email])

  customer = Customer.create!(
    first_name: data[:first_name],
    last_name: data[:last_name],
    email: data[:email],
    phone: data[:phone]
  )
  lead = Lead.new(
    first_name: data[:first_name],
    last_name: data[:last_name],
    email: data[:email],
    phone: data[:phone],
    message: data[:message],
    honeypot_value: data[:honeypot_value],
    source: "website",
    customer: customer
  )
  lead.save!
end
puts "  #{spam_data.size} spam leads with customers created"

# Test leads (non-spam) with customers for verifying safe deletion
test_lead_data = [
  { first_name: "Test", last_name: "Alpha", email: "test.alpha@example.com", phone: "248-555-0201" },
  { first_name: "Test", last_name: "Bravo", email: "test.bravo@example.com", phone: "248-555-0202" },
  { first_name: "Test", last_name: "Charlie", email: "test.charlie@example.com", phone: "248-555-0203" },
  { first_name: "Test", last_name: "Delta", email: "test.delta@example.com", phone: "248-555-0204" },
  { first_name: "Test", last_name: "Echo", email: "test.echo@example.com", phone: "248-555-0205" }
]

test_lead_data.each do |data|
  Lead.find_or_create_by!(email: data[:email]) do |l|
    l.first_name = data[:first_name]
    l.last_name = data[:last_name]
    l.phone = data[:phone]
    l.services_interested_in = ["cabinet_refacing"]
    l.message = "Test lead for verifying spam cleanup does not affect real customers."
    l.source = "website"
  end
end
puts "  #{test_lead_data.size} test leads with customers created"

puts "Done!"
